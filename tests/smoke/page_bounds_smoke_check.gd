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

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var director := root.get_node_or_null("RunRoot/RunDirector")
	var camera := root.get_node_or_null("RunRoot/CameraRig/Camera3D") as Camera3D
	var page_ground := root.get_node_or_null("RunRoot/LevelRoot/PageGround") as MeshInstance3D

	_assert_true(player != null and player.has_method("debug_integrate"), "player must expose debug movement", failures)
	_assert_true(director != null and director.has_method("debug_all_active_enemies_within_bounds"), "director must expose bounds check", failures)
	_assert_true(camera != null and camera.current, "camera must remain current", failures)

	if player != null:
		player.global_position = Vector3.ZERO
		player.debug_integrate(Vector2.RIGHT, false, 5.0)
		player.debug_integrate(Vector2.DOWN, false, 5.0)
		_assert_true(player.global_position.x <= 7.8, "player must stay inside page right bound", failures)
		_assert_true(player.global_position.z <= 4.8, "player must stay inside page lower bound", failures)
		player.debug_integrate(Vector2.LEFT, false, 10.0)
		player.debug_integrate(Vector2.UP, false, 10.0)
		_assert_true(player.global_position.x >= -7.8, "player must stay inside page left bound", failures)
		_assert_true(player.global_position.z >= -4.8, "player must stay inside page upper bound", failures)

	for index in 240:
		await physics_frame

	if director != null:
		_assert_true(director.debug_all_active_enemies_within_bounds(), "director-spawned enemies must stay in finite page bounds", failures)
	if camera != null and page_ground != null:
		_assert_true(camera.is_position_in_frustum(Vector3.ZERO), "camera must keep page center readable", failures)
		_assert_true(camera.is_position_in_frustum(page_ground.global_position), "camera must frame page ground", failures)

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
		print("page bounds smoke check passed")
		quit(0)
		return

	push_error("page bounds smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
