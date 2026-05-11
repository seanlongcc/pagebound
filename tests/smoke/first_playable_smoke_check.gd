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

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var enemy := root.get_node_or_null("RunRoot/Actors/Enemies/InklingChaser")
	var enemy_health: Node = null
	if enemy != null:
		enemy_health = enemy.get_node_or_null("HealthComponent")
	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var damage_manager := root.get_node_or_null("RunRoot/DamageNumbers/DamageNumberManager")
	var pagecraft_manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var camera := root.get_node_or_null("RunRoot/CameraRig/Camera3D") as Camera3D
	var hud := root.get_node_or_null("UI/HUD") as Control

	_assert_true(player is CharacterBody3D, "player must exist as CharacterBody3D", failures)
	_assert_true(enemy is CharacterBody3D, "enemy must spawn as CharacterBody3D", failures)
	_assert_true(enemy_health != null and enemy_health.has_method("is_alive"), "enemy must own health", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_hit_count"), "auto weapon manager must exist", failures)
	_assert_true(damage_manager != null and damage_manager.has_method("debug_spawned_count"), "damage number manager must exist", failures)
	_assert_true(pagecraft_manager != null and pagecraft_manager.has_method("debug_mark_count"), "Pagecraft manager must exist", failures)
	_assert_true(runtime != null and runtime.has_method("debug_xp_total"), "runtime XP stub must exist", failures)
	_assert_true(camera != null and camera.current, "gameplay camera must be current", failures)
	_assert_true(hud != null and hud.visible, "minimal HUD must be visible", failures)

	if player != null and player.has_method("debug_integrate"):
		var start_position: Vector3 = player.global_position
		player.debug_integrate(Vector2.RIGHT, false, 0.25)
		_assert_true(player.global_position.x > start_position.x + 0.1, "player must move", failures)

	var starting_enemy_distance := 999.0
	if enemy != null and enemy.has_method("debug_distance_to_target"):
		starting_enemy_distance = enemy.debug_distance_to_target()

	for index in 720:
		await physics_frame

	if enemy != null and enemy.has_method("debug_distance_to_target"):
		_assert_true(enemy.debug_distance_to_target() < starting_enemy_distance, "enemy must chase player", failures)
	if weapon_manager != null:
		_assert_true(weapon_manager.debug_hit_count() > 0, "auto weapon must hit", failures)
	_assert_true(_has_dead_or_despawned_enemy(root), "at least one enemy must die", failures)
	if damage_manager != null:
		_assert_true(damage_manager.debug_spawned_count() > 0, "damage numbers must spawn", failures)
	if runtime != null and runtime.debug_xp_total() == 0:
		var pickup := _first_visible_pickup(root)
		if player != null and pickup != null:
			player.global_position = Vector3(pickup.global_position.x, player.global_position.y, pickup.global_position.z)
			for pickup_index in 3:
				await physics_frame
	if runtime != null:
		_assert_true(runtime.debug_xp_total() >= 1, "collectible XP flow must award after Color Mote pickup", failures)
		_assert_true(runtime.has_method("debug_player_health"), "runtime must expose player health for HUD/contact checks", failures)
		if runtime.has_method("debug_player_health"):
			_assert_true(runtime.debug_player_health() < 50.0, "enemy contact must damage player through damage model", failures)
	_assert_true(_hud_has_text(hud, "XP"), "HUD must show XP text", failures)
	if pagecraft_manager != null:
		_assert_true(pagecraft_manager.debug_mark_count() > 0, "weapon must leave Pagecraft mark", failures)

	if player != null and pagecraft_manager != null and pagecraft_manager.has_method("debug_first_mark_position"):
		var mark_position: Vector3 = pagecraft_manager.debug_first_mark_position()
		player.global_position = mark_position - Vector3.RIGHT * 0.5
		player.debug_integrate(Vector2.RIGHT, true, 0.01)
		player.debug_integrate(Vector2.ZERO, false, 0.25)
		_assert_true(pagecraft_manager.debug_activation_count() > 0, "dash must activate Pagecraft mark", failures)

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


func _has_visible_pickup(root: Node) -> bool:
	return _first_visible_pickup(root) != null


func _first_visible_pickup(root: Node) -> Node3D:
	var pickups := root.get_node_or_null("RunRoot/Pickups")
	if pickups == null:
		return null
	for child in pickups.get_children():
		if child is Node3D and child.visible:
			return child
	return null


func _has_dead_or_despawned_enemy(root: Node) -> bool:
	var enemies := root.get_node_or_null("RunRoot/Actors/Enemies")
	if enemies == null:
		return false
	for child in enemies.get_children():
		if not child is Node3D:
			continue
		var health := child.get_node_or_null("HealthComponent")
		if health != null and health.has_method("is_alive") and not health.is_alive():
			return true
		if not (child as Node3D).visible:
			return true
	return false


func _hud_has_text(hud: Node, text_fragment: String) -> bool:
	if hud == null:
		return false
	for child in hud.get_children():
		if child is Label and child.text.contains(text_fragment):
			return true
	return false


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("first playable smoke check passed")
		quit(0)
		return

	push_error("first playable smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
