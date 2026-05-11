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
	var label := _hud_label(hud)
	_assert_true(hud != null and hud.visible, "HUD must be visible", failures)
	_assert_true(label != null, "HUD counter label must exist", failures)
	var initial_text := ""
	if label != null:
		initial_text = label.text
		_assert_true(initial_text.contains("HP") and initial_text.contains("50/50"), "HUD must show HP clearly", failures)
		_assert_true(initial_text.contains("XP"), "HUD must show XP", failures)
		_assert_true(initial_text.contains("Enemies"), "HUD must show enemy count", failures)
		_assert_true(initial_text.contains("Time"), "HUD must show run time", failures)

	for index in 120:
		await physics_frame

	if label != null:
		_assert_true(label.text != initial_text, "HUD counters must update during run", failures)
		_assert_true(label.text.contains("Enemies"), "HUD must keep enemy count after updates", failures)
		_assert_true(label.text.contains("Time"), "HUD must keep run time after updates", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _hud_label(hud: Node) -> Label:
	if hud == null:
		return null
	return hud.get_node_or_null("FirstPlayableHudLabel") as Label


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
