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

	_assert_true(runtime != null and runtime.has_method("debug_toggle_pause_menu"), "runtime must expose pause menu debug toggle", failures)
	if runtime != null and runtime.has_method("debug_apply_upgrade_choice"):
		runtime.debug_apply_upgrade_choice(&"new_weapon_waxlight_comet")
		runtime.debug_apply_upgrade_choice(&"new_passive_candle_spark")
		if runtime.has_method("debug_apply_weapon_upgrade_stat"):
			runtime.debug_apply_weapon_upgrade_stat(&"star_sticker_swarm", &"damage")
		else:
			runtime.debug_apply_upgrade_choice(&"weapon_upgrade_star_sticker_swarm")
		runtime.debug_apply_upgrade_choice(&"passive_upgrade_candle_spark")
		await process_frame

	if runtime != null and runtime.has_method("debug_toggle_pause_menu"):
		runtime.debug_toggle_pause_menu()
	await process_frame

	var pause_screen := _find_named(root, "PauseScreen") as Control
	var text := _visible_text(root.get_node_or_null("UI/ModalLayer"))
	_assert_true(paused, "pause menu must pause gameplay", failures)
	_assert_true(pause_screen != null and pause_screen.visible, "Escape/debug pause must show pause screen", failures)
	_assert_true(text.contains("Resume") and text.contains("Options") and text.contains("Quit"), "pause menu must show resume/options/quit placeholders", failures)
	_assert_true(text.contains("Star Sticker Swarm") and text.contains("Lv2"), "pause menu must show starter weapon levels and upgrades", failures)
	_assert_true(text.contains("Applied Upgrades") and text.contains("Star Strike"), "pause menu must list each weapon's applied upgrades", failures)
	_assert_true(text.contains("Waxlight Comet") and text.contains("Lv1"), "pause menu must show second weapon stats", failures)
	_assert_true(text.contains("Candle Spark") and text.contains("Lv2"), "pause menu must show passive item levels", failures)

	if runtime != null and runtime.has_method("debug_toggle_pause_menu"):
		runtime.debug_toggle_pause_menu()
	await process_frame
	_assert_true(not paused, "resume must unpause gameplay", failures)

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
	if node is CanvasItem and not (node as CanvasItem).visible:
		return ""
	var text := ""
	if node is Label and node.visible:
		text += (node as Label).text + "\n"
	if node is Button and node.visible:
		text += (node as Button).text + "\n"
	for child in node.get_children():
		text += _visible_text(child)
	return text


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("pause menu smoke check passed")
		quit(0)
		return

	push_error("pause menu smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
