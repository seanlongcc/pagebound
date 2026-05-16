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

	_assert_true(runtime != null and runtime.has_method("debug_boss_state"), "runtime must expose boss state", failures)
	_assert_true(runtime != null and runtime.has_method("debug_damage_boss"), "runtime must expose boss damage debug hook", failures)

	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(60.0)
		runtime.debug_force_run_time(210.0)
	await process_frame
	var boss_state := _boss_state(runtime)
	_assert_true(bool(boss_state.get("queued_for_event", false)), "Crownless Echo must queue while Color Well is active", failures)
	_assert_true(not bool(boss_state.get("active", false)), "Crownless Echo must not overlap active Page Event", failures)
	_assert_true(_visible_text(root.get_node_or_null("UI/HUD")).contains("Fill the Color Well"), "event banner must remain while boss is queued", failures)

	if runtime != null and runtime.has_method("debug_advance_page_event"):
		runtime.debug_advance_page_event(61.0)
	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(211.0)
	await process_frame
	await physics_frame
	boss_state = _boss_state(runtime)
	_assert_true(boss_state.get("id", &"") == &"crownless_echo", "Crownless Echo must spawn after event resolves", failures)
	_assert_true(bool(boss_state.get("active", false)), "Crownless Echo must become active", failures)
	_assert_true(is_equal_approx(float(boss_state.get("contact_damage", 0.0)), 240.0), "Crownless Echo contact damage must be 50% above old 160 baseline", failures)
	_assert_true(int(boss_state.get("hp_percent", 0)) > 0 and int(boss_state.get("hp_percent", 0)) <= 100, "boss banner data must expose HP percent", failures)
	_assert_true(_visible_text(root.get_node_or_null("UI/HUD")).contains("Crownless Echo"), "boss banner must replace event banner after event resolves", failures)

	if runtime != null and runtime.has_method("debug_damage_boss"):
		runtime.debug_damage_boss(99999.0)
	await process_frame
	await physics_frame
	boss_state = _boss_state(runtime)
	_assert_true(bool(boss_state.get("defeated", false)), "Crownless Echo must be killable", failures)
	_assert_true(runtime != null and runtime.has_method("debug_draft_is_open") and not runtime.debug_draft_is_open(), "Crownless Echo defeat must not open an in-run draft", failures)
	_assert_true(_visible_pickup_count(root) > 0, "Crownless Echo defeat must drop XP/Color Motes", failures)

	if runtime != null and runtime.has_method("debug_force_run_time"):
		runtime.debug_force_run_time(300.0)
	await process_frame
	_assert_true(runtime != null and runtime.has_method("debug_run_ended") and not runtime.debug_run_ended(), "run must not hard stop at 5:00", failures)
	_assert_true(not _screen_visible(root, "VictoryScreen"), "5:00 must not force vertical-slice victory summary", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _boss_state(runtime: Node) -> Dictionary:
	if runtime != null and runtime.has_method("debug_boss_state"):
		return runtime.debug_boss_state()
	return {}


func _visible_pickup_count(root: Node) -> int:
	var count := 0
	var pickups := root.get_node_or_null("RunRoot/Pickups")
	if pickups == null:
		return 0
	for child in pickups.get_children():
		if child is Node3D and child.visible:
			count += 1
	return count


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
		print("crownless echo smoke check passed")
		quit(0)
		return

	push_error("crownless echo smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
