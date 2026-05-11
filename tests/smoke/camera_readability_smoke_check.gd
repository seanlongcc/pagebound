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

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player") as CharacterBody3D
	var camera_rig := root.get_node_or_null("RunRoot/CameraRig") as Node3D
	var camera := root.get_node_or_null("RunRoot/CameraRig/Camera3D") as Camera3D
	var page_ground := root.get_node_or_null("RunRoot/LevelRoot/PageGround") as MeshInstance3D
	var enemy := _first_enemy(root)

	_assert_true(player != null, "player must exist for readability framing", failures)
	_assert_true(camera_rig != null, "camera rig must exist", failures)
	_assert_true(camera != null and camera.current, "camera must be current", failures)
	_assert_true(page_ground != null, "page ground must exist", failures)
	_assert_true(enemy != null, "nearby enemy must exist for readability framing", failures)

	if camera != null:
		var pitch_degrees := _camera_pitch_degrees(camera)
		_assert_true(pitch_degrees >= 60.0 and pitch_degrees <= 70.0, "camera pitch must be more top-down but not flat 2D", failures)
		_assert_true(camera.position.y >= 7.5, "camera height must support top-down page readability", failures)
		_assert_true(camera.fov >= 56.0 and camera.fov <= 62.0, "camera FOV must preserve page readability after angle tune", failures)

	if player != null and enemy != null:
		enemy.global_position = player.global_position + Vector3.RIGHT
		await _settle_camera()
		_assert_frame(camera, player.global_position, "camera must frame player at page center", failures)
		_assert_frame(camera, page_ground.global_position, "camera must frame page center", failures)
		_assert_frame(camera, enemy.global_position, "camera must frame nearby enemy at page center", failures)

	var edge_positions := [
		Vector3(7.2, 0.0, 4.2),
		Vector3(-7.2, 0.0, -4.2),
	]
	for edge_position in edge_positions:
		if player != null:
			player.global_position = edge_position
		if enemy != null:
			enemy.global_position = edge_position + Vector3(-0.8, 0.0, 0.0)
		await _settle_camera()
		_assert_frame(camera, edge_position, "camera must frame player at finite page edge %s" % edge_position, failures)
		_assert_frame(camera, page_ground.global_position, "camera must keep page center readable from edge %s" % edge_position, failures)
		if enemy != null:
			_assert_frame(camera, enemy.global_position, "camera must frame nearby enemy at edge %s" % edge_position, failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _settle_camera() -> void:
	for frame_index in 45:
		await physics_frame


func _camera_pitch_degrees(camera: Camera3D) -> float:
	var forward := -camera.global_transform.basis.z.normalized()
	return rad_to_deg(asin(clampf(absf(forward.y), 0.0, 1.0)))


func _assert_frame(camera: Camera3D, world_position: Vector3, message: String, failures: Array[String]) -> void:
	if camera == null:
		failures.append(message)
		return
	_assert_true(camera.is_position_in_frustum(world_position + Vector3.UP * 0.35), message, failures)


func _first_enemy(root: Node) -> Node3D:
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	if enemies_root == null:
		return null
	for child in enemies_root.get_children():
		if child is Node3D:
			return child
	return null


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
		print("camera readability smoke check passed")
		quit(0)
		return

	push_error("camera readability smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
