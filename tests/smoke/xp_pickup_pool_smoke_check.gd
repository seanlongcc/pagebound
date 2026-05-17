extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const XpPickupPoolScript := preload("res://src/pickups/xp_pickup_pool.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	await _assert_standalone_pool_merges_and_reuses(failures)
	await _assert_runtime_pickups_stay_bounded(failures)
	_finish(failures)


func _assert_standalone_pool_merges_and_reuses(failures: Array[String]) -> void:
	var root := Node3D.new()
	root.name = "Pickups"
	get_root().add_child(root)
	var collector := Node3D.new()
	collector.name = "Collector"
	get_root().add_child(collector)
	var pool = XpPickupPoolScript.new()
	get_root().add_child(pool)
	pool.pickup_hard_cap = 3
	pool.merge_radius = 1.0
	pool.configure(root, collector)

	var first: Node = pool.spawn_pickup(Vector3.ZERO, 5)
	var merged: Node = pool.spawn_pickup(Vector3(0.5, 0.0, 0.0), 5)
	_assert_equal(merged, first, "nearby Color Motes must merge into one pickup", failures)
	_assert_equal(int(first.amount), 10, "merged Color Mote must preserve XP amount", failures)
	_assert_equal(pool.debug_active_count(), 1, "merge must keep one active pickup", failures)

	var second: Node = pool.spawn_pickup(Vector3(3.0, 0.0, 0.0), 5)
	var third: Node = pool.spawn_pickup(Vector3(6.0, 0.0, 0.0), 5)
	var overflow: Node = pool.spawn_pickup(Vector3(9.0, 0.0, 0.0), 5)
	_assert_true(second != null and third != null and overflow != null, "pool must provide or merge overflow pickup requests", failures)
	_assert_true(pool.debug_active_count() <= 3, "pool must enforce pickup hard cap", failures)
	_assert_true(pool.debug_merged_count() >= 2, "pool must track nearby and overflow merges", failures)

	first.collect_by_assist(&"smoke")
	await process_frame
	_assert_equal(pool.debug_active_count(), 2, "collected pickup must return to inactive pool", failures)
	var reused: Node = pool.spawn_pickup(Vector3(12.0, 0.0, 0.0), 5)
	_assert_equal(reused, first, "pool must reuse returned pickup", failures)
	_assert_true(pool.debug_reused_count() >= 1, "pool must expose reuse count", failures)

	pool.queue_free()
	root.queue_free()
	collector.queue_free()
	await process_frame


func _assert_runtime_pickups_stay_bounded(failures: Array[String]) -> void:
	var root := _load_main(failures)
	if root == null:
		return
	await process_frame
	await physics_frame
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	_assert_true(runtime != null and runtime.has_method("debug_start_run"), "runtime must expose start helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_spawn_xp_pickup"), "runtime must expose XP pickup spawn helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_xp_pickup_pool_stats"), "runtime must expose XP pickup pool stats", failures)
	if runtime == null:
		root.queue_free()
		return

	runtime.debug_start_run()
	await process_frame
	await physics_frame
	for index in 420:
		runtime.debug_spawn_xp_pickup(Vector3(float(index) * 2.0, 0.0, 0.0), 5)

	var pickups_root := root.get_node("RunRoot/Pickups")
	var stats: Dictionary = runtime.debug_xp_pickup_pool_stats()
	_assert_true(int(stats.get("hard_cap", 0)) > 0, "runtime pool stats must include hard cap", failures)
	_assert_true(pickups_root.get_child_count() <= int(stats.get("hard_cap", 0)), "runtime pickup children must stay at or below hard cap", failures)
	_assert_true(int(stats.get("active", 0)) <= int(stats.get("hard_cap", 0)), "runtime active pickups must stay at or below hard cap", failures)
	_assert_true(int(stats.get("merged", 0)) > 0, "runtime pool must merge overflow XP when capped", failures)

	root.queue_free()
	await process_frame


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


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("xp pickup pool smoke check passed")
		quit(0)
		return

	push_error("xp pickup pool smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
