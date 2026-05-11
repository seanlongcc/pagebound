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
	var director := root.get_node_or_null("RunRoot/RunDirector")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	_assert_true(runtime != null and runtime.has_method("damage_model"), "runtime must expose damage model", failures)
	_assert_true(director != null and director.has_method("debug_spawned_enemy_ids"), "director must expose spawned enemy IDs", failures)

	for index in 240:
		await physics_frame

	if director != null and director.has_method("debug_spawned_enemy_ids"):
		var spawned_ids: Array = director.debug_spawned_enemy_ids()
		_assert_true(spawned_ids.has(&"inkling_chaser"), "slow sturdy chaser family must spawn", failures)
		_assert_true(spawned_ids.has(&"paper_scrap_swarmer"), "fast weak swarmer family must spawn", failures)

	var chaser := _first_enemy_with_id(enemies_root, &"inkling_chaser")
	var swarmer := _first_enemy_with_id(enemies_root, &"paper_scrap_swarmer")
	_assert_true(chaser != null, "chaser instance must expose family ID", failures)
	_assert_true(swarmer != null, "swarmer instance must expose family ID", failures)
	if chaser != null and swarmer != null:
		_assert_true(swarmer.move_speed > chaser.move_speed, "swarmer must be faster than chaser", failures)
		_assert_true(_max_health(swarmer) < _max_health(chaser), "swarmer must have less health than chaser", failures)

	var target := _first_living_enemy(enemies_root)
	_assert_true(target != null, "must have a living enemy for lifecycle check", failures)
	if target != null and runtime != null:
		var health := target.get_node_or_null("HealthComponent")
		runtime.damage_model().apply_damage(health, &"smoke_test", 999.0, [&"smoke_test"])
		await physics_frame
		_assert_true(not target.visible, "dead enemy must visibly despawn", failures)
		_assert_true(not target.is_physics_processing(), "dead enemy must stop physics processing", failures)
		_assert_true(target.has_method("debug_is_targetable") and not target.debug_is_targetable(), "dead enemy must stop being targetable", failures)
		var collision := target.get_node_or_null("CollisionShape3D") as CollisionShape3D
		_assert_true(collision != null and collision.disabled, "dead enemy collision must be disabled", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _first_enemy_with_id(enemies_root: Node, enemy_id: StringName) -> Node:
	if enemies_root == null:
		return null
	for child in enemies_root.get_children():
		if child.has_method("debug_enemy_id") and child.debug_enemy_id() == enemy_id:
			return child
	return null


func _first_living_enemy(enemies_root: Node) -> Node:
	if enemies_root == null:
		return null
	for child in enemies_root.get_children():
		if child.has_method("debug_is_targetable") and child.debug_is_targetable():
			return child
	return null


func _max_health(enemy: Node) -> float:
	var health := enemy.get_node_or_null("HealthComponent")
	if health != null and "max_health" in health:
		return health.max_health
	return 0.0


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
		print("enemy loop smoke check passed")
		quit(0)
		return

	push_error("enemy loop smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
