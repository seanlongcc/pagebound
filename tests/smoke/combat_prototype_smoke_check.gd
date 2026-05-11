extends SceneTree

const MAIN_SCENE := "res://Main.tscn"


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame

	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var enemy := root.get_node_or_null("RunRoot/Actors/Enemies/InklingChaser")
	var enemy_health: Node = null
	if enemy != null:
		enemy_health = enemy.get_node_or_null("HealthComponent")

	_assert_true(runtime != null and runtime.has_method("debug_xp_total"), "runtime must expose XP reward stub", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_hit_count"), "weapon manager must exist", failures)
	_assert_true(enemy != null and enemy.has_method("debug_distance_to_target"), "placeholder enemy must spawn", failures)
	_assert_true(enemy_health != null and enemy_health.has_method("is_alive"), "enemy must own HealthComponent", failures)

	var starting_distance := 999.0
	if enemy != null:
		starting_distance = enemy.debug_distance_to_target()

	for index in 420:
		await physics_frame

	if enemy != null:
		_assert_true(enemy.debug_distance_to_target() < starting_distance, "enemy must chase player", failures)
	if weapon_manager != null:
		_assert_true(weapon_manager.debug_hit_count() > 0, "auto weapon must hit enemy through damage model", failures)
	if enemy_health != null:
		_assert_true(not enemy_health.is_alive(), "enemy must be killable by placeholder weapon", failures)
	if runtime != null and runtime.has_method("debug_xp_total"):
		_assert_true(runtime.debug_xp_total() >= 1, "enemy death must award XP stub", failures)

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


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("combat prototype smoke check passed")
		quit(0)
		return

	push_error("combat prototype smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
