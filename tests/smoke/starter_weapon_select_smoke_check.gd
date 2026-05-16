extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const STAR_WEAPON_ID := &"star_sticker_swarm"
const WAXLIGHT_WEAPON_ID := &"waxlight_comet"


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame

	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var modal_layer := root.get_node_or_null("UI/ModalLayer") as Control
	_assert_true(runtime != null and runtime.has_method("debug_run_started"), "runtime must expose run-start state", failures)
	_assert_true(runtime != null and runtime.has_method("debug_owned_weapon_ids"), "runtime must expose owned weapon IDs", failures)
	_assert_true(runtime != null and runtime.has_method("debug_weapon_level"), "runtime must expose weapon level lookup", failures)
	_assert_true(_screen_visible(root, "StartScreen"), "boot must show start menu first", failures)
	_assert_true(not _screen_visible(root, "StarterWeaponScreen"), "starter weapon screen must be hidden before Start Run", failures)

	_press_button(root, "UI/ModalLayer/StartScreen/StartButton", failures)
	await process_frame

	_assert_true(_screen_visible(root, "StarterWeaponScreen"), "Start Run must open starter weapon select screen", failures)
	_assert_true(not _screen_visible(root, "StartScreen"), "starter weapon select must replace start screen", failures)
	if runtime != null and runtime.has_method("debug_run_started"):
		_assert_true(not runtime.debug_run_started(), "run must remain idle while selecting starter weapon", failures)
	var select_text := _visible_text(modal_layer)
	_assert_true(select_text.contains("Star Sticker Swarm"), "starter select must offer Star Sticker Swarm", failures)
	_assert_true(select_text.contains("Waxlight Comet"), "starter select must offer Waxlight Comet", failures)

	_press_button(root, "UI/ModalLayer/StarterWeaponScreen/WaxlightCometButton", failures)
	await process_frame
	await physics_frame
	_assert_starter_weapon(root, runtime, WAXLIGHT_WEAPON_ID, failures)

	if runtime != null and runtime.has_method("debug_return_to_main_menu"):
		runtime.debug_return_to_main_menu()
		await process_frame
		await physics_frame

	_press_button(root, "UI/ModalLayer/StartScreen/StartButton", failures)
	await process_frame
	_press_button(root, "UI/ModalLayer/StarterWeaponScreen/StarStickerSwarmButton", failures)
	await process_frame
	await physics_frame
	_assert_starter_weapon(root, runtime, STAR_WEAPON_ID, failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _assert_starter_weapon(root: Node, runtime: Node, weapon_id: StringName, failures: Array[String]) -> void:
	if runtime == null:
		return
	_assert_true(runtime.debug_run_started(), "selecting starter weapon must begin the run", failures)
	var owned_ids: Array[StringName] = runtime.debug_owned_weapon_ids()
	_assert_true(owned_ids == [weapon_id], "run must start with selected starter weapon only", failures)
	if runtime.has_method("debug_weapon_level"):
		_assert_true(runtime.debug_weapon_level(weapon_id) == 1, "selected starter weapon must begin at level 1", failures)
	_assert_true(not _screen_visible(root, "StarterWeaponScreen"), "starter weapon screen must hide after selection", failures)


func _press_button(root: Node, path: NodePath, failures: Array[String]) -> void:
	var button := root.get_node_or_null(path) as Button
	_assert_true(button != null, "missing button: %s" % String(path), failures)
	if button != null:
		button.emit_signal("pressed")


func _screen_visible(root: Node, screen_name: String) -> bool:
	if root == null:
		return false
	var screen := root.get_node_or_null("UI/ModalLayer/%s" % screen_name) as Control
	return screen != null and screen.visible


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
		print("starter weapon select smoke check passed")
		quit(0)
		return

	push_error("starter weapon select smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
