extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const STAR_WEAPON_ID := &"star_sticker_swarm"


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")

	_assert_true(runtime != null and runtime.has_method("debug_start_run"), "runtime must expose debug_start_run", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_weapon_upgrade_stat"), "runtime must expose weapon stat upgrade helper", failures)
	if runtime == null or not runtime.has_method("debug_start_run"):
		_finish_after_root(root, failures)
		return

	runtime.debug_start_run()
	await process_frame
	await physics_frame

	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	var enemy_registry := root.get_node_or_null("RunRoot/ActiveEnemyRegistry")
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_fire_weapon_at"), "weapon manager must expose selected fire helper", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_pending_star_ricochet_segment_jobs"), "weapon manager must expose queued Star ricochet job count", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_drain_star_ricochet_segment_jobs"), "weapon manager must expose deterministic Star ricochet drain helper", failures)
	_assert_true(enemies_root != null, "enemies root must exist", failures)
	if not failures.is_empty():
		_finish_after_root(root, failures)
		return

	weapon_manager.set_physics_process(false)

	await _advance_star_to_level(runtime, 5)
	_clear_children(enemies_root)
	if enemy_registry != null and enemy_registry.has_method("clear"):
		enemy_registry.clear()

	for index in 9:
		await _create_star_node(weapon_manager, enemies_root, "StarL10BudgetNode%d" % index, Vector3(float(index) * 0.9, 0.0, 0.0))

	await _advance_star_to_level(runtime, 10)
	var line_victim := _spawn_victim(enemies_root, "StarL10BudgetLineVictim", Vector3(0.45, 0.0, 0.0), 5000.0)
	var new_node_target := _spawn_victim(enemies_root, "StarL10BudgetNewNode", Vector3(-0.9, 0.0, 0.0), 5000.0)
	var line_health_before := _health_value(line_victim)
	var segment_count_before: int = weapon_manager.debug_star_ricochet_segment_count()
	var damage_count_before: int = weapon_manager.debug_star_ricochet_damage_count()

	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, new_node_target)
	var pending_after_shot: int = weapon_manager.debug_pending_star_ricochet_segment_jobs()
	_assert_true(pending_after_shot > 0, "large L10 Star chain must queue ricochet segments instead of resolving all during the shot", failures)
	_assert_true(weapon_manager.debug_star_ricochet_segment_count() == segment_count_before, "L10 Star shot must not synchronously process queued ricochet segments", failures)
	_assert_true(weapon_manager.debug_star_ricochet_damage_count() == damage_count_before, "L10 Star shot must not synchronously apply queued ricochet damage", failures)

	weapon_manager.debug_drain_star_ricochet_segment_jobs()
	_assert_true(weapon_manager.debug_pending_star_ricochet_segment_jobs() > 0, "large L10 Star chain must spread ricochet work across multiple frames", failures)
	_assert_true(weapon_manager.debug_star_ricochet_segment_count() > segment_count_before, "queued L10 Star ricochet segments must process on drain frames", failures)

	for _frame in 120:
		weapon_manager.debug_drain_star_ricochet_segment_jobs()
	_assert_true(weapon_manager.debug_pending_star_ricochet_segment_jobs() == 0, "queued L10 Star ricochet segments must drain after bounded work frames", failures)
	_assert_true(_health_value(line_victim) < line_health_before, "queued L10 Star ricochet must preserve segment damage after draining", failures)

	_finish_after_root(root, failures)


func _advance_star_to_level(runtime: Node, target_level: int) -> void:
	while runtime.debug_weapon_level(STAR_WEAPON_ID) < target_level:
		runtime.debug_apply_weapon_upgrade_stat(STAR_WEAPON_ID, &"active_cap")
		await physics_frame


func _create_star_node(weapon_manager: Node, enemies_root: Node, node_name: String, position: Vector3) -> void:
	var enemy := _spawn_victim(enemies_root, node_name, position, 5000.0)
	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, enemy)
	await process_frame
	await physics_frame
	enemy.queue_free()
	await process_frame


func _spawn_victim(enemies_root: Node, node_name: String, position: Vector3, max_health: float) -> CharacterBody3D:
	var victim := CharacterBody3D.new()
	victim.name = node_name
	enemies_root.add_child(victim)
	victim.global_position = position
	var health := HealthComponentScript.new()
	health.name = "HealthComponent"
	victim.add_child(health)
	health.configure(StringName(node_name.to_snake_case()), max_health, &"enemy")
	return victim


func _health_value(enemy: Node) -> float:
	if enemy == null:
		return 0.0
	var health := enemy.get_node_or_null("HealthComponent")
	if health == null:
		return 0.0
	return float(health.current_health)


func _clear_children(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()


func _finish_after_root(root: Node, failures: Array[String]) -> void:
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


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("star L10 ricochet budget check passed")
		quit(0)
		return

	push_error("star L10 ricochet budget check failed:\n- " + "\n- ".join(failures))
	quit(1)
