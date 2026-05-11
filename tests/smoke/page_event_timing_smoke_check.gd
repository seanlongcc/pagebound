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

	_assert_true(runtime != null and runtime.has_method("debug_force_run_time"), "runtime must expose run time forcing", failures)
	_assert_true(runtime != null and runtime.has_method("debug_active_page_event_id"), "runtime must expose active Page Event ID", failures)

	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(59.0)
	await process_frame
	_assert_true(runtime != null and runtime.debug_active_page_event_id() == &"", "59s simulated time must not start prototype Page Event", failures)
	_assert_true(not _screen_visible(root, "VictoryScreen"), "59s simulated time must not show summary", failures)

	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(60.0)
	await process_frame
	_assert_true(runtime != null and runtime.debug_active_page_event_id() == &"fill_color_well", "60s simulated time must start prototype Page Event", failures)
	_assert_true(_visible_text(root.get_node_or_null("UI/HUD")).contains("Fill the Color Well"), "HUD must show event objective at 60s", failures)
	_assert_true(not _screen_visible(root, "VictoryScreen"), "60s prototype Page Event must not end 5-minute summary", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _screen_visible(root: Node, screen_name: String) -> bool:
	var screen := _find_named(root, screen_name) as Control
	return screen != null and screen.visible


func _find_named(node: Node, node_name: String) -> Node:
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found := _find_named(child, node_name)
		if found != null:
			return found
	return null


func _visible_text(node: Node) -> String:
	if node == null:
		return ""
	var text := ""
	if node is Label and node.visible:
		text += (node as Label).text + "\n"
	if node is Button and node.visible:
		text += (node as Button).text + "\n"
	for child in node.get_children():
		text += _visible_text(child)
	return text


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
		print("page event timing smoke check passed")
		quit(0)
		return

	push_error("page event timing smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
