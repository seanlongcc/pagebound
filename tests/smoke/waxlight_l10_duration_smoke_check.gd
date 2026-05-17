extends SceneTree

const DamageModelScript := preload("res://src/combat/damage_model.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const PagecraftManagerScript := preload("res://src/pagecraft/pagecraft_manager.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var state = RunUpgradeStateScript.new()
	state.configure(PrototypeContentFactoryScript.new())
	state.debug_set_draft_seed(1)
	state.apply_choice(&"new_weapon_waxlight_comet")

	_assert_true(_weapon_upgrade_has_stat(state.debug_eligible_choices_for_level(3), &"waxlight_comet", &"duration"), "Waxlight duration must be eligible before L10 because it scales the L5 active window", failures)

	var duration_choice := _find_duration_choice_with_rarity(state, &"epic", 3)
	_assert_true(not duration_choice.is_empty(), "test must find an Epic Waxlight duration card before L10 for +50% window coverage", failures)
	if not duration_choice.is_empty():
		state.apply_choice(duration_choice.get("id", &""))
	_assert_true(state.weapon_level(&"waxlight_comet") == 2, "Waxlight duration card must advance Waxlight normally before L10", failures)
	_assert_true(state.waxlight_active_duration_seconds(1.0) >= 1.5, "Epic Waxlight duration must scale the L5 active window from 1.0s to at least 1.5s", failures)

	for stat in [&"damage", &"range", &"effect_count"]:
		var safe_choice: StringName = state.debug_weapon_upgrade_choice_id(&"waxlight_comet", stat)
		_assert_true(safe_choice != &"", "Waxlight safe upgrade helper must remain available before L5", failures)
		state.apply_choice(safe_choice)
	_assert_true(state.weapon_level(&"waxlight_comet") == 5, "Waxlight must reach L5 before testing duration-scaled active marks", failures)

	var pagecraft_root := Node3D.new()
	pagecraft_root.name = "PagecraftSmokeRoot"
	get_root().add_child(pagecraft_root)
	var enemies_root := Node.new()
	enemies_root.name = "EnemiesSmokeRoot"
	get_root().add_child(enemies_root)
	var manager = PagecraftManagerScript.new()
	manager.name = "PagecraftManager"
	pagecraft_root.add_child(manager)
	manager.configure(null, pagecraft_root, DamageModelScript.new(), enemies_root, state)
	await process_frame

	manager.debug_deposit_test_mark(Vector3.ZERO)
	var l5_late_victim := _spawn_victim(enemies_root, "WaxlightL5DurationLateTick", Vector3(8.0, 0.0, 0.0), 20.0)
	var l5_late_health := l5_late_victim.get_node("HealthComponent")
	manager.activate_path(Vector3(-0.2, 0.0, 0.0), Vector3(0.2, 0.0, 0.0))
	await physics_frame
	for _frame in 66:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() == 1, "L5 Waxlight duration scaling must keep the mark active past the default 1.0s window", failures)
	l5_late_victim.global_position = Vector3.ZERO
	for _frame in 30:
		await physics_frame
	_assert_true(l5_late_health.current_health < l5_late_health.max_health, "L5 Waxlight duration scaling must add an extra 0.33s tick after the default window", failures)
	for _frame in 20:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() == 0, "L5 Waxlight duration-scaled active mark must still expire after the extended window", failures)

	for stat in [&"damage", &"range", &"effect_count", &"active_cap", &"damage"]:
		var l10_choice: StringName = state.debug_weapon_upgrade_choice_id(&"waxlight_comet", stat)
		_assert_true(l10_choice != &"", "Waxlight safe upgrade helper must remain available before L10", failures)
		state.apply_choice(l10_choice)
	_assert_true(state.weapon_level(&"waxlight_comet") == 10, "Waxlight must reach L10 before testing connected duration scaling", failures)
	_assert_true(state.waxlight_active_duration_seconds(1.0) * 2.0 >= 3.0, "L10 Waxlight active window formula must be scaled L5 duration times 2", failures)

	manager.debug_clear_marks()
	manager.debug_deposit_test_mark(Vector3.ZERO)
	manager.debug_deposit_test_mark(Vector3(1.3, 0.0, 0.0))
	var late_victim := _spawn_victim(enemies_root, "WaxlightDurationLateTick", Vector3(8.0, 0.0, 0.0), 20.0)
	var late_health := late_victim.get_node("HealthComponent")
	manager.activate_path(Vector3(-0.2, 0.0, 0.0), Vector3(0.2, 0.0, 0.0))
	await physics_frame
	for _frame in 132:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() >= 2, "L10 Waxlight duration scaling must keep connected marks active past the default 2.0s window", failures)
	late_victim.global_position = Vector3(1.3, 0.0, 0.0)
	for _frame in 14:
		await physics_frame
	_assert_true(late_health.current_health < late_health.max_health, "L10 Waxlight duration scaling must add extra .33s ticks after the default window", failures)
	for _frame in 70:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() == 0, "L10 Waxlight duration-scaled active marks must still expire after the extended window", failures)

	pagecraft_root.queue_free()
	enemies_root.queue_free()
	await process_frame
	_finish(failures)


func _find_duration_choice_with_rarity(state, rarity: StringName, run_level: int) -> Dictionary:
	for seed in 5000:
		state.debug_set_draft_seed(seed)
		for choice in state.debug_eligible_choices_for_level(run_level):
			if choice.get("choice_type", &"") == &"weapon_upgrade" and choice.get("weapon_id", &"") == &"waxlight_comet" and choice.get("stat_id", &"") == &"duration" and choice.get("rarity", &"") == rarity:
				return choice
	return {}


func _weapon_upgrade_has_stat(choices: Array[Dictionary], weapon_id: StringName, stat_id: StringName) -> bool:
	for choice in choices:
		if choice.get("choice_type", &"") == &"weapon_upgrade" and choice.get("weapon_id", &"") == weapon_id and choice.get("stat_id", &"") == stat_id:
			return true
	return false


func _spawn_victim(enemies_root: Node, node_name: String, position: Vector3, max_health: float) -> CharacterBody3D:
	var victim := CharacterBody3D.new()
	victim.name = node_name
	enemies_root.add_child(victim)
	victim.global_position = position
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
		print("waxlight L10 duration smoke check passed")
		quit(0)
		return

	push_error("waxlight L10 duration smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
