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

	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")

	_assert_true(runtime != null and runtime.has_method("debug_apply_upgrade_choice"), "runtime must expose upgrade helper", failures)
	_assert_true(player != null and player.has_method("debug_integrate"), "player must support dash sampling", failures)
	_assert_true(manager != null and manager.has_method("debug_deposit_test_mark"), "Pagecraft manager must expose test mark deposit", failures)
	_assert_true(manager != null and manager.has_method("debug_unactivated_mark_count"), "Pagecraft manager must expose inactive mark count", failures)
	_assert_true(manager != null and manager.has_method("debug_active_mark_count"), "Pagecraft manager must expose active mark count", failures)
	_assert_true(manager != null and manager.has_method("debug_unactivated_mark_cap"), "Pagecraft manager must expose inactive mark cap", failures)
	_assert_true(manager != null and manager.has_method("debug_activation_duration_seconds"), "Pagecraft manager must expose activation duration", failures)
	_assert_true(manager != null and manager.has_method("debug_clear_marks"), "Pagecraft manager must support smoke mark reset", failures)

	if (
		runtime == null
		or player == null
		or manager == null
		or enemies_root == null
		or not manager.has_method("debug_clear_marks")
		or not manager.has_method("debug_activation_duration_seconds")
		or not manager.has_method("debug_unactivated_mark_cap")
		or not manager.has_method("debug_deposit_test_mark")
		or not manager.has_method("debug_unactivated_mark_count")
		or not manager.has_method("debug_active_mark_count")
	):
		_finish_after_root(root, failures)
		return

	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	if weapon_manager != null:
		weapon_manager.set_physics_process(false)

	manager.debug_clear_marks()
	var base_duration := 0.0
	if manager.has_method("debug_activation_duration_seconds"):
		base_duration = manager.debug_activation_duration_seconds()
	runtime.debug_apply_upgrade_choice(&"weapon_upgrade_waxlight_comet")
	runtime.debug_apply_upgrade_choice(&"weapon_upgrade_waxlight_comet")
	runtime.debug_apply_upgrade_choice(&"weapon_upgrade_waxlight_comet")
	_assert_true(manager.debug_activation_duration_seconds() > base_duration, "duration upgrade must extend active Waxlight duration", failures)

	var base_cap: int = manager.debug_unactivated_mark_cap()
	for index in base_cap + 2:
		manager.debug_deposit_test_mark(Vector3(float(index) * 0.4, 0.0, -2.0))
	_assert_true(manager.debug_unactivated_mark_count() == base_cap, "unactivated Waxlight marks must respect cap", failures)

	for index in 3:
		manager.debug_deposit_test_mark(Vector3(float(index) * 0.4, 0.0, -3.0))
	_assert_true(manager.debug_unactivated_mark_count() == base_cap, "unactivated Waxlight marks must keep respecting cap after upgrades", failures)

	manager.debug_clear_marks()
	manager.debug_deposit_test_mark(Vector3.ZERO)
	_assert_true(manager.debug_unactivated_mark_count() == 1, "inactive Waxlight test mark must deposit", failures)
	for _frame in 780:
		await physics_frame
	_assert_true(manager.debug_unactivated_mark_count() == 0, "unactivated Waxlight marks must expire after finite inactive lifetime", failures)

	manager.debug_clear_marks()
	var mark_position := Vector3.ZERO
	manager.debug_deposit_test_mark(mark_position)
	var touching_victim := _spawn_victim(enemies_root, "TouchingWaxVictim", mark_position + Vector3(0.25, 0.0, 0.0), 20.0)
	var outside_victim := _spawn_victim(enemies_root, "OutsideWaxVictim", mark_position + Vector3(0.9, 0.0, 0.0), 20.0)

	player.global_position = mark_position - Vector3.RIGHT * 0.8
	player.debug_integrate(Vector2.RIGHT, true, 0.01)
	player.debug_integrate(Vector2.ZERO, false, 0.25)
	for frame_index in 4:
		await physics_frame

	var touching_health := touching_victim.get_node("HealthComponent")
	var outside_health := outside_victim.get_node("HealthComponent")
	_assert_true(touching_health.current_health < 20.0, "activated Waxlight must damage enemy touching mark", failures)
	_assert_true(is_equal_approx(outside_health.current_health, 20.0), "activated Waxlight must not damage enemy outside mark radius", failures)
	_assert_true(manager.debug_active_mark_count() > 0, "activated Waxlight must remain active during decay duration", failures)
	_assert_true(_visible_named_count(root, "WaxlightDashPulse") > 0, "Waxlight dash activation must create visible pulse feedback", failures)

	for _frame in 90:
		await physics_frame
	_assert_true(_visible_named_count(root, "WaxlightDashPulse") == 0, "Waxlight dash pulse visual must clean itself up", failures)

	for frame_index in int(ceil(manager.debug_activation_duration_seconds() * 60.0)) + 20:
		await physics_frame
	_assert_true(manager.debug_active_mark_count() == 0, "activated Waxlight must decay after active duration", failures)

	_finish_after_root(root, failures)


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


func _finish_after_root(root: Node, failures: Array[String]) -> void:
	paused = false
	root.queue_free()
	await process_frame
	_finish(failures)


func _visible_named_count(root: Node, name_prefix: String) -> int:
	var count := 0
	if root == null:
		return count
	if String(root.name).begins_with(name_prefix) and _node_visible(root):
		count += 1
	for child in root.get_children():
		count += _visible_named_count(child, name_prefix)
	return count


func _node_visible(node: Node) -> bool:
	if node is Node3D:
		return (node as Node3D).visible
	if node is CanvasItem:
		return (node as CanvasItem).visible
	return true


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("waxlight contact decay smoke check passed")
		quit(0)
		return

	push_error("waxlight contact decay smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
