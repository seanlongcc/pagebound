extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const TEST_SIZES := [
	Vector2i(960, 540),
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
]


func _initialize() -> void:
	var failures: Array[String] = []
	for viewport_size in TEST_SIZES:
		await _run_size_case(viewport_size, failures)
	_finish(failures)


func _run_size_case(viewport_size: Vector2i, failures: Array[String]) -> void:
	paused = false
	get_root().size = viewport_size
	get_root().content_scale_size = viewport_size
	DisplayServer.window_set_size(viewport_size)
	var root := _load_main(failures)
	if root == null:
		return

	await process_frame
	await physics_frame
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	await physics_frame
	player = root.get_node_or_null("RunRoot/Actors/Players/Player")
	await _open_draft(runtime, player)
	await process_frame

	var title := _find_named(root, "DraftTitle") as Control
	var buttons := _draft_buttons(root)
	var hud_label := _find_named(root, "FirstPlayableHudLabel") as Control
	var actual_viewport_size := Vector2i(get_root().get_visible_rect().size)

	_assert_true(title != null and title.visible, "%s draft title must be visible" % [viewport_size], failures)
	_assert_true(buttons.size() == 3, "%s draft must have exactly 3 visible cards" % [viewport_size], failures)
	if title != null:
		_assert_true(_rect_inside(title.get_global_rect(), actual_viewport_size), "%s draft title must stay inside viewport" % [viewport_size], failures)
		if buttons.size() == 3:
			var first_size := buttons[0].size
			var border_colors: Array[Color] = []
			for button in buttons:
				var button_rect := button.get_global_rect()
				_assert_true(_rect_inside(button_rect, actual_viewport_size), "%s draft card must stay inside viewport rect=%s" % [viewport_size, button_rect], failures)
				_assert_true(absf(button.size.x - first_size.x) <= 1.0, "%s draft cards must have equal width" % [viewport_size], failures)
				_assert_true(absf(button.size.y - first_size.y) <= 1.0, "%s draft cards must have equal height" % [viewport_size], failures)
				_assert_true(button.size.y >= button.size.x * 0.95, "%s draft card must be vertical/card-shaped" % [viewport_size], failures)
				_assert_wrapped_card_text(button, viewport_size, failures)
				_assert_rarity_border(button, viewport_size, failures)
				if button.has_meta("rarity_border_color"):
					border_colors.append(button.get_meta("rarity_border_color"))
			_assert_true(_has_multiple_border_colors(border_colors), "%s draft rarity borders must differ across rarity levels" % [viewport_size], failures)
			_assert_true(_cards_are_ordered(buttons), "%s draft cards must be centered in one row" % [viewport_size], failures)

	if hud_label != null and hud_label.is_visible_in_tree():
		var hud_rect := hud_label.get_global_rect()
		if title != null:
			_assert_true(not title.get_global_rect().intersects(hud_rect), "%s draft title must not overlap HUD label" % [viewport_size], failures)
		for button in buttons:
			_assert_true(not button.get_global_rect().intersects(hud_rect), "%s draft card must not overlap HUD label" % [viewport_size], failures)

	paused = false
	root.queue_free()
	await process_frame


func _open_draft(runtime: Node, player: Node) -> void:
	if runtime == null or player == null or not runtime.has_method("debug_spawn_xp_pickup"):
		return
	var guard := 0
	while runtime.has_method("debug_draft_is_open") and not runtime.debug_draft_is_open() and guard < 10:
		runtime.debug_spawn_xp_pickup((player as Node3D).global_position, 1)
		await physics_frame
		guard += 1


func _rect_inside(rect: Rect2, viewport_size: Vector2i) -> bool:
	return rect.position.x >= 0.0 and rect.position.y >= 0.0 and rect.end.x <= float(viewport_size.x) and rect.end.y <= float(viewport_size.y)


func _cards_are_ordered(buttons: Array[Button]) -> bool:
	if buttons.size() != 3:
		return false
	return absf(buttons[0].global_position.y - buttons[1].global_position.y) < 8.0 and absf(buttons[1].global_position.y - buttons[2].global_position.y) < 8.0 and buttons[0].global_position.x < buttons[1].global_position.x and buttons[1].global_position.x < buttons[2].global_position.x


func _assert_wrapped_card_text(button: Button, viewport_size: Vector2i, failures: Array[String]) -> void:
	var text := _visible_text(button)
	_assert_true(not text.contains("..."), "%s draft card text must not show ellipsis truncation" % [viewport_size], failures)
	_assert_true(not button.clip_text, "%s draft card text must not be clipped by Button clip_text" % [viewport_size], failures)
	_assert_true(button.text_overrun_behavior == TextServer.OVERRUN_NO_TRIMMING, "%s draft card text must not trim overrun with ellipsis" % [viewport_size], failures)
	if "autowrap_mode" in button:
		_assert_true(button.autowrap_mode != TextServer.AUTOWRAP_OFF, "%s draft card text must use autowrap" % [viewport_size], failures)
	_assert_true(text.contains("\n"), "%s draft card text must be arranged as wrapped/multiline content" % [viewport_size], failures)


func _assert_rarity_border(button: Button, viewport_size: Vector2i, failures: Array[String]) -> void:
	_assert_true(button.has_meta("rarity_border_color"), "%s draft card must expose rarity border color metadata" % [viewport_size], failures)
	var stylebox := button.get_theme_stylebox("normal")
	_assert_true(stylebox is StyleBoxFlat, "%s draft card normal style must be StyleBoxFlat for rarity border" % [viewport_size], failures)
	if stylebox is StyleBoxFlat:
		var flat := stylebox as StyleBoxFlat
		_assert_true(flat.border_width_top > 0 and flat.border_width_bottom > 0, "%s draft card must have visible top/bottom rarity border" % [viewport_size], failures)
		_assert_true(flat.border_width_left > 0 and flat.border_width_right > 0, "%s draft card must have visible left/right rarity border" % [viewport_size], failures)


func _has_multiple_border_colors(colors: Array[Color]) -> bool:
	if colors.size() < 2:
		return false
	var first := colors[0]
	for color in colors:
		if color != first:
			return true
	return false


func _draft_buttons(root: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	_collect_draft_buttons(root, buttons)
	return buttons


func _collect_draft_buttons(node: Node, buttons: Array[Button]) -> void:
	if node is Button and String(node.name).begins_with("DraftChoice") and node.visible:
		buttons.append(node)
	for child in node.get_children():
		_collect_draft_buttons(child, buttons)


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
		print("draft layout scaling smoke check passed")
		quit(0)
		return

	push_error("draft layout scaling smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
