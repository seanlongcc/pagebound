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
	var waxlight = factory.waxlight_comet_weapon()

	_assert_true(waxlight != null and "base_range_meters" in waxlight, "weapon data must expose base_range_meters", failures)
	_assert_true(upgrade_state.has_method("weapon_range_meters"), "upgrade state must expose weapon_range_meters", failures)
	var base_range := 0.0
	if waxlight != null and "base_range_meters" in waxlight:
		base_range = float(waxlight.base_range_meters)
		_assert_true(base_range > 0.0, "weapon range_meters must be positive", failures)
	if upgrade_state.has_method("weapon_range_meters"):
		_assert_true(is_equal_approx(upgrade_state.weapon_range_meters(&"waxlight_comet", base_range), base_range), "base weapon range must be unchanged before range upgrade", failures)

	var before_damage := upgrade_state.weapon_damage(&"waxlight_comet", 5.0)
	var before_cooldown := upgrade_state.weapon_cooldown_seconds(&"waxlight_comet", 1.15)
	var range_event: Dictionary = upgrade_state.apply_choice(&"waxlight_range_plus")
	_assert_true(not range_event.is_empty(), "Waxlight range upgrade card must apply", failures)
	if upgrade_state.has_method("weapon_range_meters"):
		_assert_true(is_equal_approx(upgrade_state.weapon_range_meters(&"waxlight_comet", base_range), base_range + 1.5), "Waxlight range upgrade must add exactly 1.5m", failures)
	_assert_true(is_equal_approx(upgrade_state.weapon_damage(&"waxlight_comet", 5.0), before_damage), "range upgrade must not change weapon damage", failures)
	_assert_true(is_equal_approx(upgrade_state.weapon_cooldown_seconds(&"waxlight_comet", 1.15), before_cooldown), "range upgrade must not change weapon cooldown", failures)

	var owner := Node3D.new()
	owner.name = "RangeOwner"
	get_root().add_child(owner)
	owner.position = Vector3.ZERO
	var enemies_root := Node3D.new()
	enemies_root.name = "RangeEnemies"
	get_root().add_child(enemies_root)
	var event_bus := RuntimeEventBusScript.new()
	get_root().add_child(event_bus)
	var damage_model = DamageModelScript.new()
	damage_model.configure(event_bus)
	var manager = AutoWeaponManagerScript.new()
	get_root().add_child(manager)

	var runtime_state = RunUpgradeStateScript.new()
	runtime_state.configure(factory)
	manager.configure(owner, enemies_root, damage_model, waxlight, null, runtime_state, factory)
	_assert_true(manager.has_method("debug_weapon_range_meters"), "weapon manager must expose per-weapon range debug", failures)
	if manager.has_method("debug_weapon_range_meters"):
		base_range = manager.debug_weapon_range_meters(&"waxlight_comet")

	var far_enemy := _spawn_victim(enemies_root, "FarRangeVictim", owner.position + Vector3.RIGHT * (base_range + 1.0), 20.0)
	for far_frame in 90:
		await physics_frame
	_assert_true(manager.debug_weapon_hit_count(&"waxlight_comet") == 0, "Waxlight must not hit enemies beyond its max range", failures)

	far_enemy.queue_free()
	await process_frame
	var close_enemy := _spawn_victim(enemies_root, "CloseRangeVictim", owner.position + Vector3.RIGHT * maxf(0.5, base_range - 0.5), 20.0)
	for close_frame in 90:
		await physics_frame
	_assert_true(manager.debug_weapon_hit_count(&"waxlight_comet") > 0, "Waxlight must hit enemies inside its max range", failures)
	close_enemy.queue_free()
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


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("weapon range smoke check passed")
		quit(0)
		return

	push_error("weapon range smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
