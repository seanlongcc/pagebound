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
	var director := root.get_node_or_null("RunRoot/RunDirector")
	var modal_layer := root.get_node_or_null("UI/ModalLayer") as Control
	var level_up_screen := root.get_node_or_null("UI/ModalLayer/LevelUpScreen") as Control
	var opened_events: Array[Dictionary] = []
	var selected_events: Array[Dictionary] = []

	_assert_true(runtime != null and runtime.has_method("debug_spawn_xp_pickup"), "runtime must expose smoke pickup spawn helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_draft_is_open"), "runtime must expose draft open state", failures)
	_assert_true(runtime != null and runtime.has_method("debug_draft_choice_count"), "runtime must expose draft choice count", failures)
	_assert_true(runtime != null and runtime.has_method("debug_accept_focused_draft_choice"), "runtime must expose draft accept helper", failures)
	_assert_true(event_bus != null and event_bus.has_signal("draft_opened"), "event bus must emit draft opened event", failures)
	_assert_true(event_bus != null and event_bus.has_signal("draft_choice_selected"), "event bus must emit draft choice selected event", failures)
	_assert_true(modal_layer != null and level_up_screen != null, "existing modal UI slots must exist", failures)

	if event_bus != null and event_bus.has_signal("draft_opened"):
		event_bus.draft_opened.connect(func(event: Dictionary) -> void:
			opened_events.append(event)
		)
	if event_bus != null and event_bus.has_signal("draft_choice_selected"):
		event_bus.draft_choice_selected.connect(func(event: Dictionary) -> void:
			selected_events.append(event)
		)

	if runtime != null and player != null and runtime.has_method("debug_spawn_xp_pickup"):
		for mote_index in 3:
			runtime.debug_spawn_xp_pickup(player.global_position, 1)
			for frame_index in 3:
				await physics_frame

	_assert_true(paused, "level-up draft must pause or soft-freeze gameplay", failures)
	if runtime != null and runtime.has_method("debug_draft_is_open"):
		_assert_true(runtime.debug_draft_is_open(), "runtime must report draft open after level-up", failures)
	if runtime != null and runtime.has_method("debug_draft_choice_count"):
		_assert_true(runtime.debug_draft_choice_count() == 3, "draft must show exactly 3 choices", failures)
	_assert_true(opened_events.size() == 1, "draft opened event must emit once", failures)
	_assert_true(modal_layer != null and modal_layer.visible, "ModalLayer must be visible while draft is open", failures)
	_assert_true(level_up_screen != null and level_up_screen.visible, "LevelUpScreen must be visible while draft is open", failures)
	_assert_choice_texts(level_up_screen, failures)

	if director != null and director.has_method("debug_run_time"):
		var time_before := float(director.debug_run_time())
		for frame_index in 10:
			await process_frame
		_assert_true(is_equal_approx(float(director.debug_run_time()), time_before), "director run time must freeze while draft is open", failures)

	if runtime != null and runtime.has_method("debug_accept_focused_draft_choice"):
		runtime.debug_accept_focused_draft_choice()
		await process_frame

	_assert_true(not paused, "accepting focused draft choice must unpause gameplay", failures)
	_assert_true(level_up_screen != null and not level_up_screen.visible, "LevelUpScreen must hide after selection", failures)
	_assert_true(selected_events.size() == 1, "draft choice selected event must emit once", failures)
	if not selected_events.is_empty():
		_assert_true(selected_events[0].get("choice_id", &"") == &"new_weapon_star_sticker_swarm", "weapon-pick default focused choice must be Star Sticker Swarm", failures)

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


func _assert_choice_texts(level_up_screen: Node, failures: Array[String]) -> void:
	var buttons := _choice_buttons(level_up_screen)
	_assert_true(buttons.size() == 3, "LevelUpScreen must contain exactly 3 choice buttons", failures)
	_assert_true(_buttons_contain_text(buttons, "Star Sticker Swarm"), "weapon-pick draft must include documented second weapon", failures)
	_assert_true(_buttons_contain_text(buttons, "Paper Plane Dart"), "weapon-pick draft must include primitive Paper Plane Dart weapon", failures)
	_assert_true(_buttons_contain_text(buttons, "Margin Spark Ring"), "weapon-pick draft must include primitive Margin Spark Ring weapon", failures)
	_assert_true(_buttons_contain_text(buttons, "New Weapon"), "weapon-pick cards must label the reward category", failures)


func _choice_buttons(root: Node) -> Array[Button]:
	var buttons: Array[Button] = []
	if root == null:
		return buttons
	_collect_choice_buttons(root, buttons)
	return buttons


func _collect_choice_buttons(node: Node, buttons: Array[Button]) -> void:
	if node is Button and String(node.name).begins_with("DraftChoice"):
		buttons.append(node)
	for child in node.get_children():
		_collect_choice_buttons(child, buttons)


func _buttons_contain_text(buttons: Array[Button], text_fragment: String) -> bool:
	for button in buttons:
		if _visible_text(button).contains(text_fragment):
			return true
	return false


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


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("draft choice smoke check passed")
		quit(0)
		return

	push_error("draft choice smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
