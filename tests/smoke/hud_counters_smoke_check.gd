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

	var hud := root.get_node_or_null("UI/HUD")
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player") as Node3D
	_assert_true(hud != null and hud.visible, "HUD must be visible", failures)
	_assert_true(_find_named(hud, "FirstPlayableHudLabel") == null, "legacy debug HUD label must be removed", failures)
	var initial_text := _visible_text(hud)
	_assert_true(initial_text.contains("HP") and initial_text.contains("1000/1000"), "HUD must show HP clearly", failures)
	_assert_true(initial_text.contains("XP"), "HUD must show XP", failures)
	_assert_true(initial_text.contains("Level"), "HUD must show level badge", failures)
	_assert_true(initial_text.contains("Kills 0"), "HUD must show top-left kill counter", failures)
	_assert_true(initial_text.contains("Dog"), "HUD must show Dog pet badge", failures)
	_assert_true(not initial_text.contains("Enemies") and not initial_text.contains("Time"), "player HUD must not show debug enemy/time counters", failures)

	if runtime != null and runtime.has_method("debug_spawn_xp_pickup") and player != null:
		runtime.debug_spawn_xp_pickup(player.global_position, 5)
		for index in 3:
			await physics_frame

	var updated_text := _visible_text(hud)
	_assert_true(updated_text != initial_text, "HUD counters must update after XP changes", failures)
	_assert_true(updated_text.contains("XP"), "HUD must keep XP after updates", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


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
		print("hud counters smoke check passed")
		quit(0)
		return

	push_error("hud counters smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
