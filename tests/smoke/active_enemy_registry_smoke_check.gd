extends SceneTree

const ActiveEnemyRegistryScript := preload("res://src/runtime/active_enemy_registry.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var registry = ActiveEnemyRegistryScript.new()
	get_root().add_child(registry)

	var near_enemy := _enemy("NearEnemy", Vector3(1.0, 0.0, 0.0), true, true)
	var far_enemy := _enemy("FarEnemy", Vector3(4.0, 0.0, 0.0), true, true)
	var hidden_enemy := _enemy("HiddenEnemy", Vector3(0.5, 0.0, 0.0), true, false)
	var dead_enemy := _enemy("DeadEnemy", Vector3(0.25, 0.0, 0.0), false, true)
	get_root().add_child(near_enemy)
	get_root().add_child(far_enemy)
	get_root().add_child(hidden_enemy)
	get_root().add_child(dead_enemy)
	await process_frame

	registry.register_enemy(near_enemy)
	registry.register_enemy(far_enemy)
	registry.register_enemy(hidden_enemy)
	registry.register_enemy(dead_enemy)

	_assert_equal(registry.active_count(), 2, "registry must count only visible living enemies", failures)
	_assert_equal(registry.nearest_enemy(Vector3.ZERO, 10.0), near_enemy, "nearest query must skip hidden/dead enemies", failures)
	_assert_equal(registry.nearest_enemy(Vector3.ZERO, 0.5), null, "nearest query must respect range", failures)

	var nearby: Array[Node3D] = registry.enemies_in_radius(Vector3.ZERO, 2.0)
	_assert_equal(nearby.size(), 1, "radius query must return only active enemies inside range", failures)
	if not nearby.is_empty():
		_assert_equal(nearby[0], near_enemy, "radius query must return near active enemy", failures)

	registry.unregister_enemy(near_enemy)
	_assert_equal(registry.active_count(), 1, "unregister must remove active enemy", failures)
	_assert_equal(registry.nearest_enemy(Vector3.ZERO, 10.0), far_enemy, "nearest query must update after unregister", failures)

	registry.queue_free()
	near_enemy.queue_free()
	far_enemy.queue_free()
	hidden_enemy.queue_free()
	dead_enemy.queue_free()
	await process_frame
	_finish(failures)


func _enemy(enemy_name: String, position: Vector3, alive: bool, visible: bool) -> Node3D:
	var enemy := Node3D.new()
	enemy.name = enemy_name
	enemy.position = position
	enemy.visible = visible
	var health = HealthComponentScript.new()
	health.name = "HealthComponent"
	enemy.add_child(health)
	health.configure(StringName(enemy_name), 10.0, &"enemy")
	if not alive:
		health.apply_resolved_damage(10.0)
	return enemy


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("active enemy registry smoke check passed")
		quit(0)
		return

	push_error("active enemy registry smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
