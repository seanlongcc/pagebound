extends SceneTree

const SnapshotScript := preload("res://src/runtime/performance_profile_snapshot.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var run_root := _build_run_root()
	get_root().add_child(run_root)

	var snapshotter = SnapshotScript.new()
	var snapshot: Dictionary = snapshotter.capture(run_root, "smoke")
	var roots: Dictionary = snapshot.get("roots", {})
	var enemies: Dictionary = roots.get("enemies", {})
	var pickups: Dictionary = roots.get("pickups", {})
	var timings: Dictionary = snapshot.get("timings", {})

	_assert_equal(snapshot.get("label", ""), "smoke", "snapshot must preserve label", failures)
	_assert_true(timings.has("fps"), "snapshot must include FPS monitor", failures)
	_assert_true(timings.has("process_time_ms"), "snapshot must include process timing", failures)
	_assert_true(timings.has("physics_time_ms"), "snapshot must include physics timing", failures)
	_assert_equal(enemies.get("total_children", -1), 2, "snapshot must count enemy children", failures)
	_assert_equal(enemies.get("visible_children", -1), 1, "snapshot must count visible enemy children", failures)
	_assert_equal(enemies.get("hidden_children", -1), 1, "snapshot must count hidden enemy accumulation", failures)
	_assert_equal(pickups.get("total_children", -1), 1, "snapshot must count pickup children", failures)
	_assert_true(snapshot.get("node_count", 0) >= 1, "snapshot must include engine node count", failures)

	run_root.queue_free()
	await process_frame
	_finish(failures)


func _build_run_root() -> Node3D:
	var run_root := Node3D.new()
	run_root.name = "RunRoot"
	var actors := Node3D.new()
	actors.name = "Actors"
	run_root.add_child(actors)
	var enemies := Node3D.new()
	enemies.name = "Enemies"
	actors.add_child(enemies)
	var visible_enemy := Node3D.new()
	visible_enemy.name = "VisibleEnemy"
	enemies.add_child(visible_enemy)
	var hidden_enemy := Node3D.new()
	hidden_enemy.name = "HiddenEnemy"
	hidden_enemy.visible = false
	enemies.add_child(hidden_enemy)

	for root_name in ["Pickups", "DamageNumbers", "VFX", "Pagecraft", "Projectiles"]:
		var hot_root := Node3D.new()
		hot_root.name = root_name
		run_root.add_child(hot_root)
		if root_name == "Pickups":
			hot_root.add_child(Node3D.new())

	return run_root


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("performance profile snapshot smoke check passed")
		quit(0)
		return

	push_error("performance profile snapshot smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
