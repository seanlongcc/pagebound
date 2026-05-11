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
