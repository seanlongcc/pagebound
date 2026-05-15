extends SceneTree

const AutoWeaponManagerScript := preload("res://src/weapons/auto_weapon_manager.gd")
const DamageModelScript := preload("res://src/combat/damage_model.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var factory = PrototypeContentFactoryScript.new()
	var upgrade_state = RunUpgradeStateScript.new()
	upgrade_state.configure(factory)
	upgrade_state.apply_choice(&"new_weapon_waxlight_comet")

	var owner := Node3D.new()
	owner.name = "WaxlightAoeOwner"
	get_root().add_child(owner)
	var enemies_root := Node3D.new()
	enemies_root.name = "WaxlightAoeEnemies"
	get_root().add_child(enemies_root)
	var event_bus := RuntimeEventBusScript.new()
	get_root().add_child(event_bus)
	var damage_events: Array[Dictionary] = []
	event_bus.damage_resolved.connect(func(event: Dictionary) -> void:
		damage_events.append(event)
	)
	var damage_model = DamageModelScript.new()
	damage_model.configure(event_bus)
	var manager = AutoWeaponManagerScript.new()
	get_root().add_child(manager)
	manager.configure(owner, enemies_root, damage_model, factory.star_sticker_swarm_weapon(), null, upgrade_state, factory)
	manager.set_physics_process(false)
	await process_frame

	var primary := _spawn_victim(enemies_root, "WaxlightAoePrimary", Vector3(1.0, 0.0, 0.0), 200.0)
	var secondary := _spawn_victim(enemies_root, "WaxlightAoeSecondary", Vector3(1.45, 0.0, 0.0), 200.0)
	var outside := _spawn_victim(enemies_root, "WaxlightAoeOutside", Vector3(4.0, 0.0, 0.0), 200.0)
	manager.debug_fire_weapon_at(&"waxlight_comet", primary)
	await process_frame
	await physics_frame

	_assert_float_equal(_damage_amount(damage_events, &"waxlight_aoe_primary", &"waxlight_comet"), 45.0, 0.01, "Waxlight primary AoE target must take full weapon damage", failures)
	_assert_float_equal(_damage_amount(damage_events, &"waxlight_aoe_secondary", &"waxlight_comet_impact_splat"), 45.0, 0.01, "Waxlight secondary AoE target must take full weapon damage", failures)
	_assert_float_equal(_total_damage_to(damage_events, &"waxlight_aoe_outside"), 0.0, 0.01, "Waxlight AoE must not damage targets outside its radius", failures)

	manager.queue_free()
	event_bus.queue_free()
	enemies_root.queue_free()
	owner.queue_free()
	await process_frame
	_finish(failures)


func _spawn_victim(enemies_root: Node, node_name: String, position: Vector3, max_health: float) -> CharacterBody3D:
	var victim := CharacterBody3D.new()
	victim.name = node_name
	enemies_root.add_child(victim)
	victim.position = position
	var health := HealthComponentScript.new()
	health.name = "HealthComponent"
	victim.add_child(health)
	health.configure(StringName(node_name.to_snake_case()), max_health, &"enemy")
	return victim


func _assert_float_equal(actual: float, expected: float, tolerance: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > tolerance:
		failures.append("%s: expected %.2f, got %.2f" % [message, expected, actual])


func _damage_amount(events: Array[Dictionary], target_id: StringName, source_id: StringName) -> float:
	for event in events:
		if event.get("target_id", &"") == target_id and event.get("source_id", &"") == source_id:
			return float(event.get("amount", 0.0))
	return 0.0


func _total_damage_to(events: Array[Dictionary], target_id: StringName) -> float:
	var total := 0.0
	for event in events:
		if event.get("target_id", &"") == target_id:
			total += float(event.get("amount", 0.0))
	return total


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("waxlight AoE damage smoke check passed")
		quit(0)
		return

	push_error("waxlight AoE damage smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
