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
	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	await physics_frame

	_assert_true(runtime != null and runtime.has_method("debug_page_event_state"), "runtime must expose Page Event state", failures)
	_assert_true(runtime != null and runtime.has_method("debug_add_page_event_kill"), "runtime must expose Page Event kill-position debug hook", failures)
	_assert_true(runtime != null and runtime.has_method("debug_advance_page_event"), "runtime must expose Page Event time advance debug hook", failures)

	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(60.0)
	await process_frame

	var state := _page_event_state(runtime)
	_assert_true(state.get("id", &"") == &"fill_color_well", "1:00 must spawn Color Well", failures)
	_assert_true(bool(state.get("active", false)), "Color Well must be active after spawn", failures)
	_assert_true(int(state.get("required_progress", 0)) == 15, "Color Well must require 15 enemy deaths", failures)
	_assert_true(is_equal_approx(float(state.get("duration_seconds", 0.0)), 60.0), "Color Well timer must be 60 seconds", failures)
	_assert_true(bool(state.get("outside_current_vision", false)), "Color Well must spawn outside current vision", failures)
	_assert_true(bool(state.get("edge_marker_visible", false)), "offscreen Color Well must expose edge marker state", failures)

	var event_position: Vector3 = state.get("world_position", Vector3.ZERO)
	var radius := float(state.get("radius", 0.0))
	if runtime != null and runtime.has_method("debug_add_page_event_kill"):
		runtime.debug_add_page_event_kill(event_position + Vector3(radius + 0.75, 0.0, 0.0))
	state = _page_event_state(runtime)
	_assert_true(int(state.get("progress", -1)) == 0, "death outside Color Well circle must not count", failures)

	if runtime != null and runtime.has_method("debug_add_page_event_kill"):
		for _index in 14:
			runtime.debug_add_page_event_kill(event_position)
	state = _page_event_state(runtime)
	_assert_true(int(state.get("progress", -1)) == 14, "inside-circle deaths must count by death position", failures)
	_assert_true(runtime != null and runtime.has_method("debug_draft_is_open") and not runtime.debug_draft_is_open(), "Color Well must not reward before 15 kills", failures)

	if runtime != null and runtime.has_method("debug_add_page_event_kill"):
		runtime.debug_add_page_event_kill(event_position)
	await process_frame
	state = _page_event_state(runtime)
	_assert_true(bool(state.get("completed", false)), "15th inside-circle death must complete Color Well", failures)
	_assert_true(runtime != null and runtime.has_method("debug_active_page_event_id") and runtime.debug_active_page_event_id() == &"", "completed Color Well must stop reporting an active event id", failures)
	_assert_true(_visible_named_count(root, "ColorWellAnchor") == 0, "completed Color Well must remove world anchor visual", failures)
	_assert_true(runtime != null and runtime.has_method("debug_draft_is_open") and runtime.debug_draft_is_open(), "successful Color Well must open reward draft", failures)
	_assert_true(_visible_text(root.get_node_or_null("UI/ModalLayer/LevelUpScreen")).contains("Star Sticker Swarm") or _visible_text(root.get_node_or_null("UI/ModalLayer/LevelUpScreen")).contains("Candle Spark") or _visible_text(root.get_node_or_null("UI/ModalLayer/LevelUpScreen")).contains("Cloud Seed") or _visible_text(root.get_node_or_null("UI/ModalLayer/LevelUpScreen")).contains("Dream Thread") or _visible_text(root.get_node_or_null("UI/ModalLayer/LevelUpScreen")).contains("Ribbon Spool") or _visible_text(root.get_node_or_null("UI/ModalLayer/LevelUpScreen")).contains("Moon Button"), "Color Well reward must guarantee legal new gear when legal", failures)

	root.queue_free()
	await process_frame

	root = _load_main(failures)
	if root == null:
		_finish(failures)
		return
	await process_frame
	await physics_frame
	runtime = root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(60.0)
	if runtime != null and runtime.has_method("debug_advance_page_event"):
		runtime.debug_advance_page_event(61.0)
	await process_frame
	state = _page_event_state(runtime)
	_assert_true(bool(state.get("failed", false)), "Color Well must fail after 60s with no progress", failures)
	_assert_true(runtime != null and runtime.has_method("debug_active_page_event_id") and runtime.debug_active_page_event_id() == &"", "failed Color Well must stop reporting an active event id", failures)
	_assert_true(_visible_named_count(root, "ColorWellAnchor") == 0, "failed Color Well must remove world anchor visual", failures)
	_assert_true(runtime != null and runtime.has_method("debug_draft_is_open") and not runtime.debug_draft_is_open(), "failed Color Well must not open reward draft", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _page_event_state(runtime: Node) -> Dictionary:
	if runtime != null and runtime.has_method("debug_page_event_state"):
		return runtime.debug_page_event_state()
	return {}


func _visible_text(node: Node) -> String:
	if node == null:
		return ""
	if node is CanvasItem and not (node as CanvasItem).is_visible_in_tree():
		return ""
	var text := ""
	if node is Label and node.visible:
		text += (node as Label).text + "\n"
	if node is Button and node.visible:
		text += (node as Button).text + "\n"
	for child in node.get_children():
		text += _visible_text(child)
	return text


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
		print("color well page event smoke check passed")
		quit(0)
		return

	push_error("color well page event smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
