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

	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var player_health := player.get_node_or_null("HealthComponent") if player != null else null
	var death_events: Array[Dictionary] = []
	var event_bus := root.get_node_or_null("RunRoot/RuntimeEventBus")

	_assert_true(runtime != null and runtime.has_method("debug_run_ended"), "runtime must expose run-ended state", failures)
	_assert_true(runtime != null and runtime.has_method("debug_spawn_xp_pickup"), "runtime must expose pickup helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_upgrade_choice"), "runtime must expose upgrade helper", failures)
	_assert_true(player_health != null, "player must own HealthComponent", failures)
	_assert_true(event_bus != null and event_bus.has_signal("run_ended"), "event bus must emit run ended event", failures)

	if event_bus != null and event_bus.has_signal("run_ended"):
		event_bus.run_ended.connect(func(event: Dictionary) -> void:
			death_events.append(event)
		)

	if runtime != null and player_health != null:
		var camera_rig := root.get_node_or_null("RunRoot/CameraRig") as Node3D
		if player != null:
			player.global_position = Vector3(7.0, 0.0, 4.0)
		if camera_rig != null:
			camera_rig.global_position = Vector3(7.0, 0.0, 4.0)
		runtime.damage_model().apply_damage(player_health, &"death_smoke", 999.0, [&"smoke"])
		await process_frame

	_assert_true(paused, "player death must pause/stop gameplay", failures)
	if runtime != null and runtime.has_method("debug_run_ended"):
		_assert_true(runtime.debug_run_ended(), "runtime must enter run-ended state after player death", failures)
	_assert_true(_death_screen_visible(root), "player death must show death screen", failures)
	_assert_true(death_events.size() == 1, "player death must emit one run ended event", failures)

	var xp_before := 0
	var max_health_before := 0.0
	if runtime != null and runtime.has_method("debug_xp_total"):
		xp_before = runtime.debug_xp_total()
	if runtime != null and runtime.has_method("debug_player_max_health"):
		max_health_before = runtime.debug_player_max_health()

	if runtime != null and player != null:
		runtime.debug_spawn_xp_pickup(player.global_position, 3)
		for frame_index in 5:
			await process_frame
	if runtime != null and runtime.has_method("debug_xp_total"):
		_assert_true(runtime.debug_xp_total() == xp_before, "dead player must not collect XP", failures)

	if runtime != null:
		runtime.debug_apply_upgrade_choice(&"player_max_hp_plus_10")
		await process_frame
	if runtime != null and runtime.has_method("debug_player_max_health"):
		_assert_true(is_equal_approx(runtime.debug_player_max_health(), max_health_before), "dead player must not heal from post-death upgrade", failures)

	if runtime != null and runtime.has_method("debug_retry_run"):
		runtime.debug_retry_run()
		await process_frame
		await physics_frame
	var retry_player := root.get_node_or_null("RunRoot/Actors/Players/Player") as CharacterBody3D
	var retry_camera_rig := root.get_node_or_null("RunRoot/CameraRig") as Node3D
	_assert_true(retry_player != null, "retry must spawn a new player", failures)
	if retry_player != null:
		_assert_true(retry_player.global_position.distance_to(Vector3.ZERO) <= 0.1, "retry must reset player near spawn", failures)
	if retry_camera_rig != null:
		_assert_true(retry_camera_rig.global_position.distance_to(Vector3.ZERO) <= 0.25, "retry must snap camera rig back near spawn", failures)
	if retry_player != null and retry_player.has_method("debug_integrate") and retry_camera_rig != null:
		retry_player.debug_integrate(Vector2.RIGHT, false, 0.5)
		for _frame in 30:
			await physics_frame
		_assert_true(retry_camera_rig.global_position.x > 0.3, "camera must follow new player after retry", failures)

	paused = false
	root.queue_free()
	await process_frame
	_finish(failures)


func _death_screen_visible(root: Node) -> bool:
	var screen := root.get_node_or_null("UI/ModalLayer/DeathScreen") as Control
	if screen == null or not screen.visible:
		return false
	for child in screen.get_children():
		if child is Label and child.text.contains("Run Over"):
			return true
	return false


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
		print("player death flow smoke check passed")
		quit(0)
		return

	push_error("player death flow smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
