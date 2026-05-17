extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const HealthComponentScript := preload("res://src/combat/health_component.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame
	var _runtime_start := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	if _runtime_start != null and _runtime_start.has_method("debug_start_run"):
		_runtime_start.debug_start_run()
	await process_frame
	await physics_frame

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	var opening_enemy := root.get_node_or_null("RunRoot/Actors/Enemies/WaxImp") as Node3D
	var damage_manager := root.get_node_or_null("RunRoot/DamageNumbers/DamageNumberManager")

	_assert_true(player != null and player.has_method("debug_integrate"), "player must exist for dash activation", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_upgrade_choice"), "runtime must expose upgrade helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_weapon_upgrade_stat"), "runtime must expose selected weapon stat upgrade helper", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_fire_weapon_at"), "weapon manager must expose selected fire helper", failures)
	_assert_true(manager != null and manager.has_method("debug_first_mark_position"), "Pagecraft manager must expose mark position", failures)
	_assert_true(manager != null and manager.has_method("debug_activation_damage_count"), "Pagecraft manager must expose activation damage count", failures)
	_assert_true(enemies_root != null, "enemies root must exist", failures)
	_assert_true(damage_manager != null and damage_manager.has_method("debug_presented_count"), "damage number manager must exist", failures)
	if player != null and opening_enemy != null:
		opening_enemy.global_position = (player as Node3D).global_position + Vector3(5.0, 0.0, 0.0)

	if runtime == null or weapon_manager == null or manager == null or player == null or enemies_root == null:
		_finish_after_root(root, failures)
		return
	weapon_manager.set_physics_process(false)

	runtime.debug_apply_upgrade_choice(&"new_weapon_waxlight_comet")
	await physics_frame
	manager.debug_clear_marks()
	var mark_seed := _spawn_victim(enemies_root, "WaxlightMarkSeed", (player as Node3D).global_position + Vector3.RIGHT * 1.2, 200.0)
	weapon_manager.debug_fire_weapon_at(&"waxlight_comet", mark_seed)
	await process_frame
	await physics_frame
	_assert_true(manager.debug_mark_count() == 0, "L1-L4 Waxlight hit must not deposit a persistent mark", failures)

	var locked_victim := _spawn_victim(enemies_root, "WaxlightLockedDashVictim", (player as Node3D).global_position + Vector3.RIGHT * 0.2, 200.0)
	var locked_health := locked_victim.get_node("HealthComponent")

	var damage_numbers_before := 0
	if damage_manager != null:
		damage_manager.number_lifetime_seconds = 3.0
		damage_numbers_before = damage_manager.debug_presented_count()

	player.global_position = Vector3.ZERO - Vector3.RIGHT * 0.8
	player.debug_integrate(Vector2.RIGHT, true, 0.01)
	player.debug_integrate(Vector2.ZERO, false, 0.25)
	await process_frame
	await physics_frame

	_assert_true(locked_health.current_health == locked_health.max_health, "L1-L4 Waxlight dash must not activate nonexistent marks before dash payoff unlock", failures)
	_assert_true(manager.debug_activation_damage_count() == 0, "locked Waxlight dash must not record activation damage", failures)

	for safe_stat in [&"damage", &"range", &"effect_count", &"active_cap"]:
		runtime.debug_apply_weapon_upgrade_stat(&"waxlight_comet", safe_stat)
		await physics_frame
	manager.debug_clear_marks()
	var l5_seed := _spawn_victim(enemies_root, "WaxlightL5MarkSeed", (player as Node3D).global_position + Vector3.RIGHT * 1.2, 200.0)
	weapon_manager.debug_fire_weapon_at(&"waxlight_comet", l5_seed)
	await process_frame
	await physics_frame
	var mark_position: Vector3 = manager.debug_first_mark_position()
	var victim := _spawn_victim(enemies_root, "WaxlightDashDamageVictim", mark_position + Vector3(0.2, 0.0, 0.0), 200.0)
	var victim_health := victim.get_node("HealthComponent")
	player.global_position = mark_position - Vector3.RIGHT * 0.8
	if player.has_method("debug_force_dash_ready"):
		player.debug_force_dash_ready()
	player.debug_integrate(Vector2.RIGHT, true, 0.01)
	player.debug_integrate(Vector2.ZERO, false, 0.25)
	await process_frame
	await physics_frame

	_assert_true(victim_health.current_health < victim_health.max_health, "dash-activated Waxlight mark must damage nearby enemy", failures)
	if manager.has_method("debug_activation_damage_count"):
		_assert_true(manager.debug_activation_damage_count() > 0, "Pagecraft activation must record DamageModel routed damage", failures)
	if damage_manager != null:
		_assert_true(damage_manager.debug_presented_count() > damage_numbers_before, "dash activation damage must show active damage number", failures)
	_assert_true(_has_waxlight_pulse(root), "dash activation must leave primitive Waxlight pulse visual", failures)

	var safe_l10_stats := [&"damage", &"range", &"effect_count", &"active_cap", &"damage"]
	for stat in safe_l10_stats:
		runtime.debug_apply_weapon_upgrade_stat(&"waxlight_comet", stat)
		await physics_frame
	manager.debug_clear_marks()
	manager.debug_deposit_test_mark(Vector3.ZERO)
	manager.debug_deposit_test_mark(Vector3(1.3, 0.0, 0.0))
	manager.debug_deposit_test_mark(Vector3(4.5, 0.0, 0.0))
	var connected_a := _spawn_victim(enemies_root, "WaxlightConnectedA", Vector3.ZERO, 20.0)
	var connected_b := _spawn_victim(enemies_root, "WaxlightConnectedB", Vector3(1.3, 0.0, 0.0), 20.0)
	var third_second_connected := _spawn_victim(enemies_root, "WaxlightThirdSecondConnected", Vector3(8.0, 0.0, 0.0), 20.0)
	var late_connected := _spawn_victim(enemies_root, "WaxlightLateConnected", Vector3(8.0, 0.0, 0.0), 20.0)
	var disconnected := _spawn_victim(enemies_root, "WaxlightDisconnected", Vector3(4.5, 0.0, 0.0), 20.0)
	var connected_a_health := connected_a.get_node("HealthComponent")
	var connected_b_health := connected_b.get_node("HealthComponent")
	var third_second_connected_health := third_second_connected.get_node("HealthComponent")
	var late_connected_health := late_connected.get_node("HealthComponent")
	var disconnected_health := disconnected.get_node("HealthComponent")
	manager.activate_path(Vector3(-0.2, 0.0, 0.0), Vector3(0.2, 0.0, 0.0))
	await process_frame
	await physics_frame
	_assert_float_close(connected_a_health.current_health, 18.25, "L10 Waxlight connected tick must deal 35% activation damage immediately", failures)
	_assert_float_close(connected_b_health.current_health, 18.25, "L10 Waxlight connected tick must hit every activated connected mark immediately", failures)
	_assert_true(disconnected_health.current_health == disconnected_health.max_health, "L10 Waxlight connected burst must not activate disconnected marks", failures)
	for _frame in 12:
		await physics_frame
	third_second_connected.global_position = Vector3(1.3, 0.0, 0.0)
	for _frame in 12:
		await physics_frame
	_assert_true(third_second_connected_health.current_health < third_second_connected_health.max_health, "L10 Waxlight must tick again around 0.33s, before the old 0.5s cadence", failures)
	for _frame in 74:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() >= 2, "L10 Waxlight connected marks must stay active through the two-second ticking window", failures)
	late_connected.global_position = Vector3(1.3, 0.0, 0.0)
	for _frame in 14:
		await physics_frame
	_assert_true(late_connected_health.current_health < late_connected_health.max_health, "L10 Waxlight must tick near the end of the two-second window", failures)
	for _frame in 20:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() == 0, "default L10 Waxlight connected marks must end after the two-second tick window plus brief visual grace", failures)

	_finish_after_root(root, failures)


func _finish_after_root(root: Node, failures: Array[String]) -> void:
	root.queue_free()
	await process_frame
	_finish(failures)


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _has_waxlight_pulse(root: Node) -> bool:
	var pagecraft_root := root.get_node_or_null("RunRoot/Pagecraft")
	if pagecraft_root == null:
		return false
	for child in pagecraft_root.get_children():
		if child is MeshInstance3D and String(child.name).begins_with("WaxlightDashPulse") and child.visible:
			return true
	return false


func _has_visible_number_text(root: Node, expected_text: String) -> bool:
	var damage_root := root.get_node_or_null("RunRoot/DamageNumbers")
	if damage_root == null:
		return false
	for child in damage_root.get_children():
		if child is Label3D and child.visible and child.text == expected_text:
			return true
	return false


func _spawn_victim(enemies_root: Node, node_name: String, position: Vector3, max_health: float) -> CharacterBody3D:
	var victim := CharacterBody3D.new()
	victim.name = node_name
	enemies_root.add_child(victim)
	victim.global_position = position
	var victim_health := HealthComponentScript.new()
	victim_health.name = "HealthComponent"
	victim.add_child(victim_health)
	victim_health.configure(StringName(node_name.to_snake_case()), max_health, &"enemy")
	return victim


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_float_close(value: float, expected: float, message: String, failures: Array[String]) -> void:
	if not is_equal_approx(value, expected):
		failures.append("%s (expected %.2f, got %.2f)" % [message, expected, value])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("waxlight dash damage smoke check passed")
		quit(0)
		return

	push_error("waxlight dash damage smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
