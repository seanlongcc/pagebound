extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const EnemyPoolScript := preload("res://src/enemies/enemy_pool.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	_assert_standalone_pool_reuses_instances(failures)
	await process_frame
	await _assert_director_pool_bounds(failures)
	_finish(failures)


func _assert_standalone_pool_reuses_instances(failures: Array[String]) -> void:
	var root := Node3D.new()
	get_root().add_child(root)
	var pool = EnemyPoolScript.new()
	get_root().add_child(pool)
	pool.configure(root, Callable(self, "_create_pool_body"), 2, 0)

	var first := pool.request_instance()
	_assert_true(first != null, "pool must create first enemy", failures)
	pool.return_instance(first)
	var reused := pool.request_instance()
	_assert_equal(reused, first, "pool must reuse returned enemy", failures)
	var second := pool.request_instance()
	_assert_true(second != null and second != first, "pool must create second enemy up to cap", failures)
	var capped := pool.request_instance()
	_assert_equal(capped, null, "pool must return null at hard cap", failures)
	_assert_true(pool.debug_reused_count() >= 1, "pool must expose reuse count", failures)

	pool.queue_free()
	root.queue_free()


func _assert_director_pool_bounds(failures: Array[String]) -> void:
	var root := _load_main(failures)
	if root == null:
		return
	await process_frame
	await physics_frame
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var director := root.get_node_or_null("RunRoot/RunDirector")
	_assert_true(runtime != null and runtime.has_method("debug_start_run"), "runtime must expose debug_start_run", failures)
	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	await physics_frame
	director = root.get_node_or_null("RunRoot/RunDirector")
	_assert_true(runtime != null and runtime.has_method("debug_force_run_time"), "runtime must expose debug_force_run_time", failures)
	_assert_true(runtime != null and runtime.has_method("damage_model"), "runtime must expose damage model", failures)
	_assert_true(director != null and director.has_method("debug_enemy_pool_stats"), "director must expose enemy pool stats", failures)
	if runtime == null or director == null:
		root.queue_free()
		return

	runtime.debug_force_run_time(1620.0)
	for _warmup in 6:
		await physics_frame

	for _cycle in 3:
		_kill_visible_enemies(runtime, root.get_node("RunRoot"), 40)
		await process_frame
		for _respawn_frame in 20:
			await physics_frame

	var enemies_root := root.get_node("RunRoot/Actors/Enemies")
	var total_enemy_children := enemies_root.get_child_count()
	var safety_cap: int = director.debug_safety_enemy_cap() if director.has_method("debug_safety_enemy_cap") else 350
	_assert_true(total_enemy_children <= safety_cap + 1, "director pool must keep enemy children bounded by safety cap plus boss allowance", failures)
	if director.has_method("debug_enemy_pool_stats"):
		var stats: Dictionary = director.debug_enemy_pool_stats()
		_assert_true(int(stats.get("reused", 0)) > 0, "director must reuse returned enemy instances", failures)

	root.queue_free()
	await process_frame


func _kill_visible_enemies(runtime: Node, run_root: Node, limit: int) -> int:
	var enemies_root := run_root.get_node_or_null("Actors/Enemies")
	if enemies_root == null or runtime == null or not runtime.has_method("damage_model"):
		return 0
	var damage_model = runtime.damage_model()
	if damage_model == null or not damage_model.has_method("apply_damage"):
		return 0
	var killed := 0
	for child in enemies_root.get_children():
		if killed >= limit:
			break
		if not child is Node3D or not (child as Node3D).visible:
			continue
		var health := child.get_node_or_null("HealthComponent")
		if health == null or not health.has_method("is_alive") or not health.is_alive():
			continue
		damage_model.apply_damage(health, &"enemy_pool_smoke", 999999.0, [&"debug"])
		killed += 1
	return killed


func _create_pool_body() -> Node:
	var body := CharacterBody3D.new()
	body.name = "PooledEnemy"
	return body


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
		print("enemy pool smoke check passed")
		quit(0)
		return

	push_error("enemy pool smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
