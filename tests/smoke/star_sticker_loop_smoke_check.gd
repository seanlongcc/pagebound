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
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_node_count"), "weapon manager must expose persistent Star node count", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_ricochet_damage_count"), "weapon manager must expose Star ricochet damage count", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_node_extra_star_count"), "weapon manager must expose L10 node-fired Star count", failures)
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_trigger_star_dash_volley"), "weapon manager must expose Star dash volley helper", failures)

	if (
		runtime == null
		or weapon_manager == null
		or enemies_root == null
		or not runtime.has_method("debug_apply_upgrade_choice")
		or not weapon_manager.has_method("debug_fire_weapon_at")
		or not weapon_manager.has_method("debug_star_orbit_count")
		or not weapon_manager.has_method("debug_star_available_count")
		or not weapon_manager.has_method("debug_star_node_count")
		or not weapon_manager.has_method("debug_star_ricochet_damage_count")
		or not weapon_manager.has_method("debug_star_node_extra_star_count")
		or not weapon_manager.has_method("debug_trigger_star_dash_volley")
	):
		_finish_after_root(root, failures)
		return

	await physics_frame
	_assert_true(weapon_manager.debug_star_orbit_count() >= 1, "starter Star Sticker must create visible orbit star", failures)
	_assert_true(weapon_manager.debug_star_available_count() == weapon_manager.debug_star_orbit_count(), "orbit star must start available", failures)
	_assert_true(_visible_named_count(root, "StarStickerOrbit") >= 1, "orbit star visual must be visible", failures)

	var primary := _spawn_victim(enemies_root, "StarStickerPrimaryVictim", Vector3(1.5, 0.0, 0.0), 2000.0)
	var ricochet_victim := _spawn_victim(enemies_root, "StarStickerRicochetVictim", Vector3(1.95, 0.0, 0.0), 2000.0)
	var l10_victim := _spawn_victim(enemies_root, "StarStickerL10Victim", Vector3(2.35, 0.0, 0.0), 2000.0)
	var primary_health := primary.get_node("HealthComponent")
	var ricochet_health := ricochet_victim.get_node("HealthComponent")
	var l10_health := l10_victim.get_node("HealthComponent")
	var number_count_before := 0
	if damage_numbers != null and damage_numbers.has_method("debug_presented_count"):
		number_count_before = damage_numbers.debug_presented_count()
	var primary_before := float(primary_health.current_health)
	var ricochet_before := float(ricochet_health.current_health)

	weapon_manager.debug_fire_weapon_at(&"star_sticker_swarm", primary)
	await process_frame
	await physics_frame

	_assert_true(float(primary_health.current_health) < primary_before, "Star Sticker fire must apply immediate hit damage through DamageModel", failures)
	_assert_true(weapon_manager.debug_star_node_count() == 0, "L1 Star Sticker hit must not create Star nodes", failures)
	_assert_true(weapon_manager.debug_star_available_count() == weapon_manager.debug_star_orbit_count(), "fired star must remain available because nodes no longer hold orbit stars", failures)
	_assert_true(float(ricochet_health.current_health) == ricochet_before, "L1 Star Sticker must not ricochet", failures)
	if damage_numbers != null and damage_numbers.has_method("debug_presented_count"):
		_assert_true(damage_numbers.debug_presented_count() > number_count_before, "Star Sticker hit must spawn a damage number", failures)

	for _upgrade in 4:
		runtime.debug_apply_upgrade_choice(&"weapon_upgrade_star_sticker_swarm")
		await physics_frame

	ricochet_before = float(ricochet_health.current_health)
	weapon_manager.debug_fire_weapon_at(&"star_sticker_swarm", primary)
	await process_frame
	await physics_frame
	_assert_true(weapon_manager.debug_star_node_count() >= 1, "L5 Star Sticker hit must create a persistent Star node", failures)
	_assert_true(float(ricochet_health.current_health) < ricochet_before, "L5 Star node must ricochet to one nearby enemy", failures)
	_assert_true(weapon_manager.debug_star_ricochet_damage_count() > 0, "L5 Star ricochet must record DamageModel routed damage", failures)
	_assert_true(_visible_named_count(root, "StarStickerNode") >= 1, "persistent Star node visual must be visible", failures)

	var node_count_before_dash: int = weapon_manager.debug_star_node_count()
	var primary_before_dash := float(primary_health.current_health)
	weapon_manager.debug_trigger_star_dash_volley()
	await process_frame
	await physics_frame
	_assert_true(float(primary_health.current_health) < primary_before_dash, "L5 Star dash payoff must fire a cooldown-free normal-target volley", failures)
	_assert_true(weapon_manager.debug_star_node_count() == node_count_before_dash, "Star dash volley must not create new Star nodes", failures)

	for _upgrade in 5:
		runtime.debug_apply_upgrade_choice(&"weapon_upgrade_star_sticker_swarm")
		await physics_frame

	var extra_before := float(l10_health.current_health)
	weapon_manager.debug_fire_weapon_at(&"star_sticker_swarm", primary)
	await process_frame
	await physics_frame
	_assert_true(float(l10_health.current_health) < extra_before, "L10 Star node ricochet must fire one extra non-node star", failures)
	_assert_true(weapon_manager.debug_star_node_extra_star_count() > 0, "L10 Star node extra shot must be counted", failures)

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
