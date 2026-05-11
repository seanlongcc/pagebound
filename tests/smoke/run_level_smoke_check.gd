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
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player") as CharacterBody3D
	var event_bus := root.get_node_or_null("RunRoot/RuntimeEventBus")
	var hud := root.get_node_or_null("UI/HUD")
	var level_events: Array[Dictionary] = []

	_assert_true(runtime != null and runtime.has_method("debug_run_level"), "runtime must expose run level", failures)
	_assert_true(runtime != null and runtime.has_method("debug_current_level_xp"), "runtime must expose current level XP", failures)
	_assert_true(runtime != null and runtime.has_method("debug_xp_threshold"), "runtime must expose next XP threshold", failures)
	_assert_true(runtime != null and runtime.has_method("debug_spawn_xp_pickup"), "runtime must expose smoke pickup spawn helper", failures)
	_assert_true(player != null, "player must exist", failures)
	_assert_true(event_bus != null and event_bus.has_signal("run_level_gained"), "event bus must emit level-up event", failures)

	if event_bus != null and event_bus.has_signal("run_level_gained"):
		event_bus.run_level_gained.connect(func(event: Dictionary) -> void:
			level_events.append(event)
		)

	if runtime != null and runtime.has_method("debug_run_level"):
		_assert_true(runtime.debug_run_level() == 1, "run level must start at 1", failures)
	if runtime != null and runtime.has_method("debug_xp_threshold"):
		_assert_true(runtime.debug_xp_threshold() == 3, "prototype first XP threshold must be 3", failures)

	if runtime != null and player != null and runtime.has_method("debug_spawn_xp_pickup"):
		for mote_index in 3:
			runtime.debug_spawn_xp_pickup(player.global_position, 1)
			for frame_index in 3:
				await physics_frame

	if runtime != null and runtime.has_method("debug_run_level"):
		_assert_true(runtime.debug_run_level() == 2, "collecting enough Color Motes must raise run level", failures)
	if runtime != null and runtime.has_method("debug_xp_total"):
		_assert_true(runtime.debug_xp_total() == 3, "XP total must include collected motes", failures)
	if runtime != null and runtime.has_method("debug_current_level_xp"):
		_assert_true(runtime.debug_current_level_xp() == 0, "XP progress must reset after exact threshold level-up", failures)
	_assert_true(level_events.size() == 1, "level-up event must emit exactly once for first threshold", failures)
	if not level_events.is_empty():
		_assert_true(level_events[0].get("level", 0) == 2, "level-up event must report new level 2", failures)
	_assert_true(_hud_has_text(hud, "Level: 2"), "HUD must show run level", failures)
	_assert_true(_hud_has_text(hud, "XP: 0/6"), "HUD must show XP progress toward next level", failures)

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


func _hud_has_text(hud: Node, text_fragment: String) -> bool:
	if hud == null:
		return false
	for child in hud.get_children():
		if child is Label and child.text.contains(text_fragment):
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("run level smoke check passed")
		quit(0)
		return

	push_error("run level smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
