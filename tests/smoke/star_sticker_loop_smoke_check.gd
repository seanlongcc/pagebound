extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const STAR_WEAPON_ID := &"star_sticker_swarm"
const STAR_UPGRADE_ID := &"weapon_upgrade_star_sticker_swarm"


func _initialize() -> void:
	var failures: Array[String] = []
	await _check_l1_and_l5_constellation(failures)
	await _check_dash_constellation(failures)
	await _check_l10_constellation_chain(failures)
	_finish(failures)


func _check_l1_and_l5_constellation(failures: Array[String]) -> void:
	var context := await _setup_run(failures)
	if context.is_empty():
		return
	var root: Node = context["root"]
	var runtime: Node = context["runtime"]
	var weapon_manager: Node = context["weapon_manager"]
	var enemies_root: Node = context["enemies_root"]
	var damage_numbers: Node = context["damage_numbers"]

	await physics_frame
	_assert_true(weapon_manager.debug_star_orbit_count() >= 1, "starter Star Sticker must create visible orbit star", failures)
	_assert_true(weapon_manager.debug_star_available_count() == weapon_manager.debug_star_orbit_count(), "orbit star must start available", failures)
	_assert_true(_visible_named_count(root, "StarStickerOrbit") >= 1, "orbit star visual must be visible", failures)
	_assert_true(weapon_manager.has_method("debug_star_ricochet_segment_count"), "weapon manager must expose Star ricochet segment count", failures)

	var l1_primary := _spawn_victim(enemies_root, "StarStickerL1Primary", Vector3(1.5, 0.0, 0.0), 5000.0)
	var l1_near := _spawn_victim(enemies_root, "StarStickerL1Near", Vector3(1.9, 0.0, 0.0), 5000.0)
	var number_count_before := 0
	if damage_numbers != null and damage_numbers.has_method("debug_presented_count"):
		number_count_before = damage_numbers.debug_presented_count()
	var l1_primary_before := _health_value(l1_primary)
	var l1_near_before := _health_value(l1_near)

	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, l1_primary)
	await _settle()

	_assert_true(_health_value(l1_primary) < l1_primary_before, "Star Sticker fire must apply immediate hit damage through DamageModel", failures)
	_assert_true(weapon_manager.debug_star_node_count() == 0, "L1 Star Sticker hit must not create Star nodes", failures)
	_assert_true(weapon_manager.debug_star_available_count() == weapon_manager.debug_star_orbit_count(), "fired star must remain available because nodes no longer hold orbit stars", failures)
	_assert_true(is_equal_approx(_health_value(l1_near), l1_near_before), "L1 Star Sticker must not ricochet or hit nearby enemies", failures)
	if damage_numbers != null and damage_numbers.has_method("debug_presented_count"):
		_assert_true(damage_numbers.debug_presented_count() > number_count_before, "Star Sticker hit must spawn a damage number", failures)

	l1_primary.queue_free()
	l1_near.queue_free()
	await process_frame

	await _advance_star_to_level(runtime, 5)
	await _wait_physics_frames(16)

	var first_node_target := _spawn_victim(enemies_root, "StarStickerL5FirstNode", Vector3(3.0, 0.0, 0.0), 5000.0)
	var first_node_near := _spawn_victim(enemies_root, "StarStickerL5FirstNear", Vector3(3.25, 0.0, 0.0), 5000.0)
	var first_node_near_before := _health_value(first_node_near)
	var first_segment_count := _star_segment_count(weapon_manager)
	var first_line_count := _visible_named_count(root, "StarStickerConstellationLine")

	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, first_node_target)
	await _settle()

	_assert_true(weapon_manager.debug_star_node_count() == 1, "L5 first normal Star hit must create one Star node", failures)
	_assert_true(is_equal_approx(_health_value(first_node_near), first_node_near_before), "L5 first Star node must not ricochet until at least two current nodes exist", failures)
	_assert_true(_star_segment_count(weapon_manager) == first_segment_count, "L5 first Star node must not record a ricochet segment", failures)
	_assert_true(_visible_named_count(root, "StarStickerConstellationLine") == first_line_count, "L5 first Star node must not draw a constellation line", failures)
	_assert_true(_visible_named_count(root, "StarStickerNode") >= 1, "persistent Star node visual must be visible", failures)

	var second_node_target := _spawn_victim(enemies_root, "StarStickerL5SecondNode", Vector3(9.0, 0.0, 0.0), 5000.0)
	var line_victim := _spawn_victim(enemies_root, "StarStickerL5LineVictim", Vector3(6.0, 0.0, 0.15), 5000.0)
	var outside_width_victim := _spawn_victim(enemies_root, "StarStickerL5OutsideWidth", Vector3(6.0, 0.0, 0.35), 5000.0)
	var line_victim_before := _health_value(line_victim)
	var outside_width_before := _health_value(outside_width_victim)
	var segment_count_before := _star_segment_count(weapon_manager)
	var ricochet_damage_before: int = weapon_manager.debug_star_ricochet_damage_count()
	var constellation_line_before := _visible_named_count(root, "StarStickerConstellationLine")

	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, second_node_target)
	await _settle()

	_assert_true(weapon_manager.debug_star_node_count() == 2, "L5 second normal Star hit must leave two Star nodes", failures)
	_assert_true(_star_segment_count(weapon_manager) == segment_count_before + 1, "L5 second Star hit must create exactly one node-to-node segment", failures)
	_assert_true(_health_value(line_victim) < line_victim_before, "L5 node-to-node segment must pierce enemies along the line", failures)
	_assert_true(is_equal_approx(_health_value(outside_width_victim), outside_width_before), "Star ricochet hit width must stay fixed at 0.45m", failures)
	_assert_true(weapon_manager.debug_star_ricochet_damage_count() > ricochet_damage_before, "L5 Star ricochet must record DamageModel routed segment damage", failures)
	_assert_true(_visible_named_count(root, "StarStickerConstellationLine") > constellation_line_before, "L5 ricochet must draw a constellation line", failures)
	_assert_true(_visible_named_count(root, "StarStickerNodePulse") >= 2, "L5 ricochet must pulse linked Star nodes", failures)

	await _teardown_context(context)


func _check_dash_constellation(failures: Array[String]) -> void:
	var context := await _setup_run(failures)
	if context.is_empty():
		return
	var root: Node = context["root"]
	var runtime: Node = context["runtime"]
	var weapon_manager: Node = context["weapon_manager"]
	var enemies_root: Node = context["enemies_root"]

	await _advance_star_to_level(runtime, 5)
	await _wait_physics_frames(16)

	var node_a_enemy := _spawn_victim(enemies_root, "StarStickerDashNodeA", Vector3(3.0, 0.0, 0.0), 5000.0)
	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, node_a_enemy)
	await _settle()
	node_a_enemy.queue_free()
	await process_frame

	var one_node_target := _spawn_victim(enemies_root, "StarStickerDashOneNodeTarget", Vector3(2.75, 0.0, 0.0), 5000.0)
	var one_node_line_victim := _spawn_victim(enemies_root, "StarStickerDashOneNodeLineVictim", Vector3(3.2, 0.0, 0.0), 5000.0)
	var one_node_target_before := _health_value(one_node_target)
	var one_node_line_before := _health_value(one_node_line_victim)
	var node_count_before_dash: int = weapon_manager.debug_star_node_count()
	var segment_count_before := _star_segment_count(weapon_manager)

	weapon_manager.debug_trigger_star_dash_volley()
	await _settle()

	_assert_true(_health_value(one_node_target) < one_node_target_before, "L5 Star dash payoff must fire a cooldown-free normal-target volley", failures)
	_assert_true(weapon_manager.debug_star_node_count() == node_count_before_dash, "Star dash volley must not create new Star nodes", failures)
	_assert_true(_star_segment_count(weapon_manager) == segment_count_before, "Star dash ricochet must require at least two existing nodes", failures)
	_assert_true(is_equal_approx(_health_value(one_node_line_victim), one_node_line_before), "Star dash with one node must not damage a ricochet target", failures)

	one_node_target.queue_free()
	one_node_line_victim.queue_free()
	await process_frame

	var node_b_enemy := _spawn_victim(enemies_root, "StarStickerDashNodeB", Vector3(9.0, 0.0, 0.0), 5000.0)
	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, node_b_enemy)
	await _settle()
	node_b_enemy.queue_free()
	await process_frame
	await _wait_physics_frames(16)

	var dash_target := _spawn_victim(enemies_root, "StarStickerDashTwoNodeTarget", Vector3(8.9, 0.0, 0.0), 5000.0)
	var dash_line_victim := _spawn_victim(enemies_root, "StarStickerDashLineVictim", Vector3(6.0, 0.0, 0.0), 5000.0)
	var dash_target_before := _health_value(dash_target)
	var dash_line_before := _health_value(dash_line_victim)
	node_count_before_dash = weapon_manager.debug_star_node_count()
	segment_count_before = _star_segment_count(weapon_manager)
	var line_count_before := _visible_named_count(root, "StarStickerConstellationLine")

	weapon_manager.debug_trigger_star_dash_volley()
	await _settle()

	_assert_true(_health_value(dash_target) < dash_target_before, "L5 Star dash volley must still hit its target when ricocheting", failures)
	_assert_true(weapon_manager.debug_star_node_count() == node_count_before_dash, "Star dash ricochet must not create nodes", failures)
	_assert_true(_star_segment_count(weapon_manager) == segment_count_before + 1, "L5 Star dash with two existing nodes must create one segment", failures)
	_assert_true(_health_value(dash_line_victim) < dash_line_before, "Star dash ricochet must start from nearest existing node and pierce along the node-to-node segment", failures)
	_assert_true(_visible_named_count(root, "StarStickerConstellationLine") > line_count_before, "Star dash ricochet must draw a constellation line", failures)

	await _teardown_context(context)


func _check_l10_constellation_chain(failures: Array[String]) -> void:
	var context := await _setup_run(failures)
	if context.is_empty():
		return
	var root: Node = context["root"]
	var runtime: Node = context["runtime"]
	var weapon_manager: Node = context["weapon_manager"]
	var enemies_root: Node = context["enemies_root"]

	await _advance_star_to_level(runtime, 10)
	await _wait_physics_frames(16)

	await _create_star_node(weapon_manager, enemies_root, "StarStickerL10NodeA", Vector3(40.0, 0.0, 0.0))
	await _create_star_node(weapon_manager, enemies_root, "StarStickerL10NodeB", Vector3(46.0, 0.0, 0.0))
	await _create_star_node(weapon_manager, enemies_root, "StarStickerL10NodeC", Vector3(52.0, 0.0, 0.0))
	await _create_star_node(weapon_manager, enemies_root, "StarStickerL10NodeD", Vector3(58.0, 0.0, 0.0))
	await _wait_physics_frames(20)

	var overlap_victim := _spawn_victim(enemies_root, "StarStickerL10OverlapVictim", Vector3(46.0, 0.0, 0.0), 5000.0)
	var new_node_target := _spawn_victim(enemies_root, "StarStickerL10NewNode", Vector3(34.0, 0.0, 0.0), 5000.0)
	var overlap_before := _health_value(overlap_victim)
	var segment_count_before := _star_segment_count(weapon_manager)
	var line_count_before := _visible_named_count(root, "StarStickerConstellationLine")
	var single_segment_damage := float(weapon_manager.debug_weapon_damage(STAR_WEAPON_ID)) * 0.5

	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, new_node_target)
	await _settle()

	var expected_segments: int = weapon_manager.debug_star_node_count() - 1
	var overlap_damage := overlap_before - _health_value(overlap_victim)
	_assert_true(_star_segment_count(weapon_manager) == segment_count_before + expected_segments, "L10 Star attack must create current_node_count - 1 ricochet segments", failures)
	_assert_true(_visible_named_count(root, "StarStickerConstellationLine") >= line_count_before + expected_segments, "L10 Star attack must draw one constellation line per segment", failures)
	_assert_true(overlap_damage > single_segment_damage * 1.5, "L10 overlapping segments must be able to hit the same enemy once per segment", failures)
	_assert_true(weapon_manager.debug_star_node_extra_star_count() == 0, "L10 Star constellation must not use old node-fired extra-star behavior", failures)

	await _teardown_context(context)


func _setup_run(failures: Array[String]) -> Dictionary:
	var root := _load_main(failures)
	if root == null:
		return {}

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
	_assert_true(weapon_manager != null and weapon_manager.has_method("debug_star_node_extra_star_count"), "weapon manager must expose stale L10 node-fired Star counter for zero-regression checks", failures)
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
		await _teardown_context({"root": root})
		return {}

	weapon_manager.set_physics_process(false)

	return {
		"root": root,
		"runtime": runtime,
		"weapon_manager": weapon_manager,
		"enemies_root": enemies_root,
		"damage_numbers": damage_numbers,
	}


func _advance_star_to_level(runtime: Node, target_level: int) -> void:
	for _upgrade in maxi(0, target_level - 1):
		runtime.debug_apply_upgrade_choice(STAR_UPGRADE_ID)
		await physics_frame


func _create_star_node(weapon_manager: Node, enemies_root: Node, node_name: String, position: Vector3) -> void:
	var enemy := _spawn_victim(enemies_root, node_name, position, 5000.0)
	weapon_manager.debug_fire_weapon_at(STAR_WEAPON_ID, enemy)
	await _settle()
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


func _star_segment_count(weapon_manager: Node) -> int:
	if weapon_manager != null and weapon_manager.has_method("debug_star_ricochet_segment_count"):
		return weapon_manager.debug_star_ricochet_segment_count()
	return 0


func _settle() -> void:
	await process_frame
	await physics_frame


func _wait_physics_frames(count: int) -> void:
	for _index in maxi(0, count):
		await physics_frame


func _teardown_context(context: Dictionary) -> void:
	var root: Node = context.get("root", null)
	if root != null:
		paused = false
		root.queue_free()
		await process_frame


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
