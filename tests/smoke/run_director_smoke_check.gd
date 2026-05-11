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
	var _runtime_start := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	if _runtime_start != null and _runtime_start.has_method("debug_start_run"):
		_runtime_start.debug_start_run()
	await process_frame
	await physics_frame

	var director := root.get_node_or_null("RunRoot/RunDirector")
	_assert_true(director != null, "run director service must exist under RunRoot", failures)
	_assert_true(director != null and director.has_method("debug_spawned_count"), "director must expose spawned count", failures)
	_assert_true(director != null and director.has_method("debug_active_enemy_count"), "director must expose active enemy count", failures)
	_assert_true(director != null and director.has_method("debug_active_budget"), "director must expose active budget", failures)
	_assert_true(director != null and director.has_method("debug_all_active_enemies_within_bounds"), "director must expose finite bounds check", failures)

	if director == null:
		_finish_after_root(root, failures)
		return

	var initial_spawned: int = director.debug_spawned_count()
	for index in 360:
		await physics_frame

	_assert_true(director.debug_spawned_count() > initial_spawned, "director must spawn enemies over time", failures)
	_assert_true(director.debug_spawned_count() >= initial_spawned + 6, "opening spawn pressure must beat prior slow 6s baseline", failures)
	_assert_true(director.debug_active_enemy_count() <= director.debug_active_budget(), "director must enforce active enemy budget", failures)
	_assert_true(director.debug_active_enemy_count() <= director.debug_safety_enemy_cap(), "director safety cap must prevent runaway enemy count", failures)
	_assert_true(director.debug_all_active_enemies_within_bounds(), "director must keep active enemies inside finite page bounds", failures)

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


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("run director smoke check passed")
		quit(0)
		return

	push_error("run director smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
