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
	if runtime != null and runtime.has_method("debug_start_run"):
		runtime.debug_start_run()
	await process_frame
	await physics_frame

	var weapon_manager := root.get_node_or_null("RunRoot/Projectiles/WeaponManager")
	var enemies_root := root.get_node_or_null("RunRoot/Actors/Enemies")
	var damage_numbers := root.get_node_or_null("RunRoot/DamageNumbers/DamageNumberManager")

	_assert_true(runtime != null and runtime.has_method("debug_apply_upgrade_choice"), "runtime must expose upgrade helper", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_fire_weapon_at"), "weapon manager must expose selected fire helper", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_orbit_count"), "weapon manager must expose Star orbit count", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_available_count"), "weapon manager must expose available orbit stars", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_page_sticker_count"), "weapon manager must expose page-stuck sticker count", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_pop_damage_count"), "weapon manager must expose Star pop damage count", failures)

	if (
		runtime == null
		or weapon_manager == null
		or enemies_root == null
		or not runtime.has_method("debug_apply_upgrade_choice")
		or not weapon_manager.has_method("debug_fire_weapon_at")
		or not weapon_manager.has_method("debug_star_orbit_count")
		or not weapon_manager.has_method("debug_star_available_count")
		or not weapon_manager.has_method("debug_star_page_sticker_count")
		or not weapon_manager.has_method("debug_star_pop_damage_count")
	):
		_finish_after_root(root, failures)
		return

	runtime.debug_apply_upgrade_choice(&"new_weapon_star_sticker_swarm")
	await physics_frame
	_assert_true(weapon_manager.debug_star_orbit_count() >= 1, "acquiring Star Sticker must create visible orbit star", failures)
	_assert_true(weapon_manager.debug_star_available_count() == weapon_manager.debug_star_orbit_count(), "orbit star must start available", failures)
	_assert_true(_visible_named_count(root, "StarStickerOrbit") >= 1, "orbit star visual must be visible", failures)

	var primary := _spawn_victim(enemies_root, "StarStickerPrimaryVictim", Vector3(1.5, 0.0, 0.0), 200.0)
	var pop_victim := _spawn_victim(enemies_root, "StarStickerPopVictim", Vector3(1.75, 0.0, 0.0), 200.0)
	var primary_health := primary.get_node("HealthComponent")
	var pop_health := pop_victim.get_node("HealthComponent")
	var number_count_before := 0
	if damage_numbers != null and damage_numbers.has_method("debug_presented_count"):
		number_count_before = damage_numbers.debug_presented_count()
	var primary_before := float(primary_health.current_health)
	var pop_before := float(pop_health.current_health)

	weapon_manager.debug_fire_weapon_at(&"star_sticker_swarm", primary)
	await process_frame
	await physics_frame

	_assert_true(float(primary_health.current_health) < primary_before, "Star Sticker fire must apply immediate hit damage through DamageModel", failures)
	_assert_true(weapon_manager.debug_star_page_sticker_count() >= 1, "Star Sticker hit must create page-stuck sticker", failures)
	_assert_true(weapon_manager.debug_star_available_count() < weapon_manager.debug_star_orbit_count(), "fired star must leave orbit until pop/reform", failures)
	_assert_true(_visible_named_count(root, "StarStickerPageSticker") >= 1, "page-stuck sticker visual must be visible", failures)
	if damage_numbers != null and damage_numbers.has_method("debug_presented_count"):
		_assert_true(damage_numbers.debug_presented_count() > number_count_before, "Star Sticker hit must spawn a damage number", failures)

	for _frame in 118:
		await physics_frame

	_assert_true(weapon_manager.debug_star_pop_damage_count() > 0, "page-stuck Star Sticker must pop for AoE damage", failures)
	_assert_true(float(pop_health.current_health) < pop_before, "Star Sticker pop must damage nearby enemies through DamageModel", failures)
	_assert_true(weapon_manager.debug_star_page_sticker_count() == 0, "page-stuck sticker must clean itself up after pop", failures)
	_assert_true(weapon_manager.debug_star_available_count() == weapon_manager.debug_star_orbit_count(), "star must reform into orbit after pop", failures)
	_assert_true(_visible_named_count(root, "StarStickerPageSticker") == 0, "page-stuck sticker visual must not persist indefinitely", failures)

	_finish_after_root(root, failures)


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


func _visible_named_count(root: Node, name_prefix: String) -> int:
	var count := 0
	if root == null:
		return count
	if String(root.name).begins_with(name_prefix) and _node_visible(root):
		count += 1
	for child in root.get_children():
		count += _visible_named_count(child, name_prefix)
	return count


func _node_visible(node: Node) -> bool:
	if node is Node3D:
		return (node as Node3D).visible
	if node is CanvasItem:
		return (node as CanvasItem).visible
	return true


func _load_main(failures: Array[String]) -> Node:
	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		return null
	var root := packed_scene.instantiate()
	get_root().add_child(root)
	return root


func _finish_after_root(root: Node, failures: Array[String]) -> void:
	paused = false
	root.queue_free()
	await process_frame
	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("star sticker loop smoke check passed")
		quit(0)
		return

	push_error("star sticker loop smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
