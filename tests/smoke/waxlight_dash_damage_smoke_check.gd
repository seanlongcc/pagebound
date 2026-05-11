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

	var player := root.get_node_or_null("RunRoot/Actors/Players/Player")
	var manager := root.get_node_or_null("RunRoot/Pagecraft/PagecraftManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	var damage_manager := root.get_node_or_null("RunRoot/DamageNumbers/DamageNumberManager")

	_assert_true(player != null and player.has_method("debug_integrate"), "player must exist for dash activation", failures)
	_assert_true(manager != null and manager.has_method("debug_first_mark_position"), "Pagecraft manager must expose mark position", failures)
	_assert_true(manager != null and manager.has_method("debug_activation_damage_count"), "Pagecraft manager must expose activation damage count", failures)
	_assert_true(enemies_root != null, "enemies root must exist", failures)
	_assert_true(damage_manager != null and damage_manager.has_method("debug_spawned_count"), "damage number manager must exist", failures)

	for index in 180:
		await physics_frame

	if manager == null or player == null or enemies_root == null:
		_finish_after_root(root, failures)
		return

	var mark_position: Vector3 = manager.debug_first_mark_position()
	_assert_true(mark_position != Vector3.ZERO, "weapon must deposit a Waxlight mark before dash activation", failures)

	var victim := CharacterBody3D.new()
	victim.name = "WaxlightDashDamageVictim"
	enemies_root.add_child(victim)
	victim.global_position = mark_position + Vector3(0.2, 0.0, 0.0)
	var victim_health := HealthComponentScript.new()
	victim_health.name = "HealthComponent"
	victim.add_child(victim_health)
	victim_health.configure(&"waxlight_dash_damage_victim", 6.0, &"enemy")

	var damage_numbers_before := 0
	if damage_manager != null:
		damage_manager.number_lifetime_seconds = 3.0
		damage_numbers_before = damage_manager.debug_active_count()

	player.global_position = mark_position - Vector3.RIGHT * 0.8
	player.debug_integrate(Vector2.RIGHT, true, 0.01)
	player.debug_integrate(Vector2.ZERO, false, 0.25)
	await process_frame
	await physics_frame

	_assert_true(victim_health.current_health < victim_health.max_health, "dash-activated Waxlight mark must damage nearby enemy", failures)
	if manager.has_method("debug_activation_damage_count"):
		_assert_true(manager.debug_activation_damage_count() > 0, "Pagecraft activation must record DamageModel routed damage", failures)
	if damage_manager != null:
		_assert_true(damage_manager.debug_active_count() > damage_numbers_before, "dash activation damage must show active damage number", failures)
	_assert_true(_has_waxlight_pulse(root), "dash activation must leave primitive Waxlight pulse visual", failures)

	_finish_after_root(root, failures)


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


func _has_waxlight_pulse(root: Node) -> bool:
	var pagecraft_root := root.get_node_or_null("RunRoot/Pagecraft")
	if pagecraft_root == null:
		return false
	for child in pagecraft_root.get_children():
		if child is MeshInstance3D and String(child.name).begins_with("WaxlightDashPulse") and child.visible:
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("waxlight dash damage smoke check passed")
		quit(0)
		return

	push_error("waxlight dash damage smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
