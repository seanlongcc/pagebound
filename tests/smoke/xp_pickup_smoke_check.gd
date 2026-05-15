extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const XpPickupScript := preload("res://src/pickups/xp_pickup.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	await _assert_standalone_pickup_magnet(failures)

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

	var runtime := root.get_node_or_null("RunRoot/FirstPlayableRuntime")
	var player := root.get_node_or_null("RunRoot/Actors/Players/Player") as CharacterBody3D
	var enemy := root.get_node_or_null("RunRoot/Actors/Enemies/WaxImp") as CharacterBody3D
	var enemy_health: Node = null
	if enemy != null:
		enemy_health = enemy.get_node_or_null("HealthComponent")
	var hud := root.get_node_or_null("UI/HUD")

	_assert_true(runtime != null and runtime.has_method("debug_xp_total"), "runtime must expose XP total", failures)
	_assert_true(runtime != null and runtime.has_method("debug_player_health"), "runtime must expose player health", failures)
	_assert_true(runtime != null and runtime.has_method("debug_player_max_health"), "runtime must expose player max health", failures)
	_assert_true(player != null, "player must exist", failures)
	_assert_true(enemy != null, "enemy must exist", failures)
	_assert_true(enemy_health != null, "enemy must own health", failures)

	if runtime != null and runtime.has_method("debug_player_max_health"):
		_assert_true(is_equal_approx(runtime.debug_player_max_health(), 1000.0), "player max health must use 1000 HP GDD baseline", failures)

	if player != null and enemy != null and runtime != null and runtime.has_method("debug_player_health"):
		enemy.global_position = player.global_position + Vector3(0.35, 0.0, 0.0)
		await physics_frame
		_assert_true(is_equal_approx(runtime.debug_player_health(), 940.0), "enemy contact damage must subtract scaled damage from 1000 HP baseline", failures)
		enemy.global_position = Vector3(6.5, 0.0, 3.0)

	if runtime != null and runtime.has_method("debug_xp_total"):
		_assert_true(runtime.debug_xp_total() == 0, "XP must start at 0", failures)

	if runtime != null and runtime.has_method("damage_model") and enemy_health != null:
		runtime.damage_model().apply_damage(enemy_health, &"smoke_test", 999.0, [&"smoke_test"])
		await physics_frame

	var pickup := _first_visible_pickup(root)
	var xp_after_death: int = runtime.debug_xp_total() if runtime != null and runtime.has_method("debug_xp_total") else 0
	_assert_true(pickup != null or xp_after_death == 5, "enemy death must spawn a 5 XP Color Mote or let Dog fetch it", failures)
	if runtime != null and runtime.has_method("debug_xp_total"):
		_assert_true(runtime.debug_xp_total() == 0 or runtime.debug_xp_total() == 5, "enemy death XP must only advance through pickup collection or Dog fetch", failures)

	if player != null and pickup != null and xp_after_death == 0:
		player.global_position = pickup.global_position + Vector3(2.5, 0.0, 0.0)
		var distance_before_pull := player.global_position.distance_to(pickup.global_position)
		for pull_index in 5:
			await physics_frame
		var distance_after_pull := player.global_position.distance_to(pickup.global_position)
		var xp_after_pull: int = runtime.debug_xp_total() if runtime != null and runtime.has_method("debug_xp_total") else 0
		if pickup.visible and xp_after_pull == 0:
			_assert_true(distance_after_pull < distance_before_pull - 0.05, "Color Mote must pull toward player inside magnet range", failures)

		if pickup.visible and xp_after_pull == 0:
			player.global_position = Vector3(pickup.global_position.x, player.global_position.y, pickup.global_position.z)
			for index in 3:
				await physics_frame
	elif xp_after_death == 5:
		_assert_true(runtime != null and runtime.has_method("debug_dog_feedback_text") and runtime.debug_dog_feedback_text().contains("Dog fetch"), "Dog assist pickup path must expose feedback", failures)

	if runtime != null and runtime.has_method("debug_xp_total"):
		_assert_true(runtime.debug_xp_total() == 5, "XP must award documented Color Mote value when collected", failures)
	_assert_true(_first_visible_pickup(root) == null, "collected Color Mote must stop being visible", failures)
	_assert_true(_hud_has_text(hud, "HP") and _hud_has_text(hud, "1000"), "HUD must show max HP clearly", failures)
	_assert_true(_hud_has_text(hud, "XP"), "HUD must show XP after pickup", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _assert_standalone_pickup_magnet(failures: Array[String]) -> void:
	var collector := Node3D.new()
	collector.name = "Collector"
	get_root().add_child(collector)
	collector.position = Vector3(5.0, 0.0, 0.0)

	var pickup := XpPickupScript.new()
	pickup.name = "StandaloneColorMote"
	get_root().add_child(pickup)
	pickup.position = Vector3.ZERO
	pickup.configure(1, collector)
	var collected_amounts: Array[int] = []
	pickup.collected.connect(func(_pickup: Node, amount: int) -> void:
		collected_amounts.append(amount)
	)

	var far_before_distance := collector.position.distance_to(pickup.position)
	for index in 5:
		await physics_frame
	var far_after_distance := collector.position.distance_to(pickup.position)
	_assert_true(absf(far_after_distance - far_before_distance) <= 0.05, "standalone Color Mote must not pull from too-large current magnet distance", failures)

	collector.position = Vector3(2.5, 0.0, 0.0)
	var close_before_distance := collector.position.distance_to(pickup.position)
	for index in 5:
		await physics_frame
	var close_after_distance := collector.position.distance_to(pickup.position)
	_assert_true(close_after_distance < close_before_distance - 0.05, "standalone Color Mote must pull toward collector inside intended close magnet range", failures)
	_assert_true(pickup.visible, "standalone Color Mote must stay visible until collect radius", failures)
	_assert_true(collected_amounts.is_empty(), "standalone Color Mote must not collect before reaching collect radius", failures)

	pickup.queue_free()
	collector.queue_free()
	await process_frame


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _first_visible_pickup(root: Node) -> Node3D:
	var pickups := root.get_node_or_null("RunRoot/Pickups")
	if pickups == null:
		return null
	for child in pickups.get_children():
		if child is Node3D and child.visible:
			return child
	return null


func _hud_has_text(hud: Node, text_fragment: String) -> bool:
	if hud == null:
		return false
	if hud is CanvasItem and not (hud as CanvasItem).is_visible_in_tree():
		return false
	if hud is Label and (hud as Label).visible and (hud as Label).text.contains(text_fragment):
		return true
	if hud is Button and (hud as Button).visible and (hud as Button).text.contains(text_fragment):
		return true
	for child in hud.get_children():
		if _hud_has_text(child, text_fragment):
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("xp pickup smoke check passed")
		quit(0)
		return

	push_error("xp pickup smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
