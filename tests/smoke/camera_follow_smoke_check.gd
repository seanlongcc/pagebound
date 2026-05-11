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

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var camera_rig := root.get_node_or_null("RunRoot/CameraRig") as Node3D
	var camera := root.get_node_or_null("RunRoot/CameraRig/Camera3D") as Camera3D
	var light := root.get_node_or_null("RunRoot/Lighting/DirectionalLight3D") as DirectionalLight3D
	var page_ground := root.get_node_or_null("RunRoot/LevelRoot/PageGround") as MeshInstance3D

	_assert_true(player != null and player.has_method("debug_integrate"), "player must exist for camera target", failures)
	_assert_true(camera_rig != null, "camera rig must exist", failures)
	_assert_true(camera != null and camera.current, "camera must exist and be current", failures)
	_assert_true(light != null and light.visible and light.light_energy > 0.0, "directional light must remain readable", failures)

	if player != null and camera_rig != null and camera != null and page_ground != null:
		player.debug_integrate(Vector2.RIGHT, false, 1.0)
		for index in 20:
			await physics_frame

		_assert_true(camera_rig.global_position.x > 0.5, "camera rig must follow player movement", failures)
		_assert_true(camera.is_position_in_frustum(player.global_position + Vector3.UP * 0.4), "camera must frame player", failures)
		_assert_true(camera.is_position_in_frustum(page_ground.global_position), "camera must keep paper page readable", failures)

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
		print("camera follow smoke check passed")
		quit(0)
		return

	push_error("camera follow smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
