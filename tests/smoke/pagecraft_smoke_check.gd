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

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var enemy := root.get_node_or_null("RunRoot/Actors/Enemies/WaxImp") as Node3D
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	_assert_true(player != null and player.has_method("debug_integrate"), "player must exist for dash sampling", failures)
	_assert_true(runtime != null and runtime.has_method("debug_apply_upgrade_choice"), "runtime must expose upgrade helper", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_fire_weapon_at"), "weapon manager must expose selected fire helper", failures)
	_assert_true(manager != null and manager.has_method("debug_mark_count"), "Pagecraft manager must exist", failures)
	if player != null and enemy != null:
		enemy.global_position = (player as Node3D).global_position + Vector3(1.5, 0.0, 0.0)

	if runtime != null:
		runtime.debug_apply_upgrade_choice(&"new_weapon_waxlight_comet")
	if weapon_manager != null and enemy != null:
		weapon_manager.debug_fire_weapon_at(&"waxlight_comet", enemy)

	for index in 3:
		await physics_frame

	if manager != null:
		_assert_true(manager.debug_mark_count() == 0, "L1-L4 Waxlight hit must show attack visual only and leave no persistent Pagecraft mark", failures)
		_assert_true(not _has_visible_pagecraft_mark(root), "L1-L4 Waxlight must not leave visible Pagecraft mark", failures)

	if player != null and manager != null and manager.has_method("debug_first_mark_position"):
		for _upgrade in 4:
			runtime.debug_apply_upgrade_choice(&"weapon_upgrade_waxlight_comet")
		if enemy != null:
			var health := enemy.get_node_or_null("HealthComponent")
			if health != null and health.has_method("configure"):
				health.configure(&"pagecraft_l5_smoke_enemy", 1000.0, &"enemy")
		if weapon_manager != null and enemy != null:
			weapon_manager.debug_fire_weapon_at(&"waxlight_comet", enemy)
		await process_frame
		await physics_frame
		_assert_true(manager.debug_mark_count() > 0, "L5 Waxlight hit must leave visible Pagecraft mark", failures)
		_assert_true(_has_visible_pagecraft_mark(root), "L5 Waxlight Pagecraft mark visual must be visible under Pagecraft root", failures)
		var mark_position: Vector3 = manager.debug_first_mark_position()
		player.global_position = mark_position - Vector3.RIGHT * 0.5
		player.debug_integrate(Vector2.RIGHT, true, 0.01)
		player.debug_integrate(Vector2.ZERO, false, 0.25)
		await process_frame
		_assert_true(manager.debug_activation_count() > 0, "dash through L5 Waxlight mark must activate Pagecraft", failures)

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


func _has_visible_pagecraft_mark(root: Node) -> bool:
	var pagecraft_root := root.get_node_or_null("RunRoot/Pagecraft")
	if pagecraft_root == null:
		return false
	for child in pagecraft_root.get_children():
		if child is MeshInstance3D and child.visible:
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("pagecraft smoke check passed")
		quit(0)
		return

	push_error("pagecraft smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
