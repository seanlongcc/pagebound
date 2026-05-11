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

	var bus := root.get_node_or_null("RunRoot/RuntimeEventBus")
	var manager := root.get_node_or_null("RunRoot/DamageNumbers/DamageNumberManager")
	var damage_root := root.get_node_or_null("RunRoot/DamageNumbers")
	_assert_true(bus != null and bus.has_method("emit_damage_resolved"), "runtime event bus must exist", failures)
	_assert_true(manager != null and manager.has_method("debug_active_count"), "damage number manager must exist", failures)

	if bus != null and manager != null:
		var active_before: int = manager.debug_active_count()
		bus.emit_damage_resolved({
			"source_id": &"smoke_weapon",
			"target_id": &"target_dummy",
			"amount": 7.0,
			"world_position": Vector3.ZERO,
			"killed": false,
		})
		await process_frame

		_assert_equal(manager.debug_active_count(), active_before + 1, "damage event must spawn one active pooled number", failures)
		_assert_true(_has_visible_number_text(damage_root, "7"), "damage number text must show resolved amount", failures)
		_assert_true(manager.debug_spawned_count() >= 1, "damage manager must expose pool spawned count", failures)

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


func _has_visible_number_text(root: Node, expected_text: String) -> bool:
	if root == null:
		return false
	for child in root.get_children():
		if child is Label3D and child.visible and child.text == expected_text:
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("damage numbers smoke check passed")
		quit(0)
		return

	push_error("damage numbers smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
