extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const HealthComponentScript := preload("res://src/combat/health_component.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var root := _load_main(failures)
	if root == null:
		_finish(failures)
		return

	await process_frame
	await physics_frame
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	var enemy_registry := root.get_node_or_null("RunRoot/ActiveEnemyRegistry")
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	_assert_true(runtime != null and runtime.has_method("debug_start_run"), "runtime must expose debug_start_run", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_upgrade_choice"), "runtime must expose direct upgrade helper", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_weapon_upgrade_stat"), "runtime must expose weapon stat upgrade helper", failures)
	_assert_true(manager != null and manager.has_method("debug_deposit_test_mark"), "Pagecraft manager must expose test mark helper", failures)
	_assert_true(manager != null and manager.has_method("debug_pending_activation_damage_jobs"), "Pagecraft manager must expose queued activation damage job count", failures)
	_assert_true(enemies_root != null, "enemies root must exist", failures)
	if runtime == null or manager == null or enemies_root == null or not manager.has_method("debug_pending_activation_damage_jobs"):
		_finish_after_root(root, failures)
		return

	runtime.debug_start_run()
	await process_frame
	await physics_frame
	if weapon_manager != null:
		weapon_manager.set_physics_process(false)
	runtime.debug_apply_upgrade_choice(&"new_weapon_waxlight_comet")
	for stat in [&"damage", &"range", &"effect_count", &"active_cap", &"damage", &"range", &"active_cap", &"damage", &"duration"]:
		runtime.debug_apply_weapon_upgrade_stat(&"waxlight_comet", stat)
		await physics_frame

	manager.debug_clear_marks()
	manager.base_unactivated_mark_cap = 32
	_clear_children(enemies_root)
	if enemy_registry != null and enemy_registry.has_method("clear"):
		enemy_registry.clear()
	var first_victim: CharacterBody3D = null
	var first_victim_health = null
	for index in 24:
		var position := Vector3(float(index) * 0.9, 0.0, 0.0)
		manager.debug_deposit_test_mark(position)
		var victim := _spawn_victim(enemies_root, "WaxlightBudgetVictim%d" % index, position, 5000.0)
		if index == 0:
			first_victim = victim
			first_victim_health = victim.get_node("HealthComponent")
	if enemy_registry != null and enemy_registry.has_method("clear"):
		enemy_registry.clear()
	await process_frame

	var damage_before: int = manager.debug_activation_damage_count()
	var first_victim_health_before := float(first_victim_health.current_health)
	manager.activate_path(Vector3(-0.2, 0.0, 0.0), Vector3(0.2, 0.0, 0.0))
	first_victim.global_position = Vector3(200.0, 0.0, 0.0)
	var pending_after_dash: int = manager.debug_pending_activation_damage_jobs()
	_assert_true(pending_after_dash > 0, "large L10 Waxlight activation must queue damage jobs instead of resolving the whole group during dash", failures)
	_assert_true(manager.debug_activation_damage_count() == damage_before, "dash call must not synchronously process queued L10 activation damage", failures)

	await physics_frame
	var pending_after_first_frame: int = manager.debug_pending_activation_damage_jobs()
	_assert_true(pending_after_first_frame > 0, "large L10 activation must spread damage work across multiple frames", failures)
	await physics_frame
	_assert_true(manager.debug_activation_damage_count() > damage_before, "queued L10 activation damage must process on the next observed physics frames", failures)

	for _frame in 180:
		await physics_frame
	_assert_true(manager.debug_pending_activation_damage_jobs() == 0, "queued L10 activation damage must drain after bounded work frames", failures)
	_assert_true(first_victim_health.current_health < first_victim_health_before, "queued L10 Waxlight damage must use enemies captured at tick time, even if they move before drain", failures)

	_finish_after_root(root, failures)


func _spawn_victim(enemies_root: Node, node_name: String, position: Vector3, max_health: float) -> CharacterBody3D:
	var victim := CharacterBody3D.new()
	victim.name = node_name
	enemies_root.add_child(victim)
	victim.global_position = position
	var victim_health := HealthComponentScript.new()
	victim_health.name = "HealthComponent"
	victim.add_child(victim_health)
	victim_health.configure(StringName(node_name.to_snake_case()), max_health, &"enemy")
	return victim


func _clear_children(root: Node) -> void:
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
		print("waxlight L10 activation budget check passed")
		quit(0)
		return

	push_error("waxlight L10 activation budget check failed:\n- " + "\n- ".join(failures))
	quit(1)
