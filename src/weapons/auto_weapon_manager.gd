class_name AutoWeaponManager
extends Node

const MvpWeaponEffectsScript := preload("res://src/weapons/mvp_weapon_effects.gd")
const StarStickerNetworkScript := preload("res://src/weapons/star_sticker_network.gd")
const STAR_TRAVEL_FEEDBACK_SECONDS := 0.22
const STAR_CONSTELLATION_FEEDBACK_SECONDS := 0.24
const WAXLIGHT_IMPACT_FEEDBACK_SECONDS := 0.28
const STAR_RICOCHET_DAMAGE_SCALE := 0.5
const STAR_RICOCHET_HIT_WIDTH_METERS := 0.45
const BASE_STAR_NODE_CAP := 5

@export_range(0.0, 40.0, 0.1) var target_range := 8.0

var _owner: Node3D
var _enemies_root: Node
var _damage_model
var _pagecraft_manager: Node
var _upgrade_state
var _content_factory
var _fallback_weapon_data: Resource
var _weapon_states: Array[Dictionary] = []
var _hit_counts: Dictionary = {}
var _star_network = StarStickerNetworkScript.new()
var _star_orbit_visuals: Array[MeshInstance3D] = []
var _star_orbit_angle := 0.0
var _star_ricochet_damage_count := 0
var _star_ricochet_segment_count := 0
var _star_node_extra_star_count := 0
var _transient_visuals: Array[Dictionary] = []


func _physics_process(delta: float) -> void:
	_tick_transient_visuals(delta)
	if _owner == null or _damage_model == null:
		return
	_star_orbit_angle += delta * 2.4
	_sync_weapon_states()
	_sync_star_orbits()
	_update_star_orbits()
	for index in _weapon_states.size():
		var state := _weapon_states[index]
		state["cooldown"] = maxf(0.0, float(state.get("cooldown", 0.0)) - delta)
		if float(state["cooldown"]) <= 0.0:
			var target := _nearest_living_enemy_for_state(state)
			if target != null:
				_fire_weapon_state_at(state, target)
				state["cooldown"] = _cooldown_for_state(state)
		_weapon_states[index] = state


## Configures the first playable auto weapon runtime.
func configure(
	owner: Node3D,
	enemies_root: Node,
	damage_model,
	weapon_data: Resource,
	pagecraft_manager: Node = null,
	upgrade_state = null,
	content_factory = null
) -> void:
	_owner = owner
	_enemies_root = enemies_root
	_damage_model = damage_model
	_fallback_weapon_data = weapon_data
	_pagecraft_manager = pagecraft_manager
	_upgrade_state = upgrade_state
	_content_factory = content_factory
	_sync_weapon_states(true)


## Returns hit count for smoke/debug checks.
func debug_hit_count() -> int:
	var total := 0
	for value in _hit_counts.values():
		total += int(value)
	return total


## Returns per-weapon hit count for smoke/debug checks.
func debug_weapon_hit_count(weapon_id: StringName) -> int:
	return int(_hit_counts.get(weapon_id, 0))


## Returns current visible Star Sticker orbit count.
func debug_star_orbit_count() -> int:
	_sync_star_orbits()
	return _star_orbit_visuals.size()


## Returns Star Sticker orbit stars ready to fire.
func debug_star_available_count() -> int:
	_sync_star_orbits()
	return _star_orbit_visuals.size()


## Returns active page-stuck Star Sticker count.
func debug_star_page_sticker_count() -> int:
	return debug_star_node_count()


## Returns the number of enemies damaged by Star Sticker pops.
func debug_star_pop_damage_count() -> int:
	return 0


## Returns active persistent Star node count.
func debug_star_node_count() -> int:
	return _star_network.node_count()


## Returns count of enemies damaged by Star node ricochets.
func debug_star_ricochet_damage_count() -> int:
	return _star_ricochet_damage_count


## Returns count of Star node-to-node ricochet segments created.
func debug_star_ricochet_segment_count() -> int:
	return _star_ricochet_segment_count


## Returns count of enemies damaged by L10 node-fired stars.
func debug_star_node_extra_star_count() -> int:
	return _star_node_extra_star_count


## Fires Star Sticker dash payoff for smoke/debug checks.
func debug_trigger_star_dash_volley() -> void:
	trigger_dash_payoffs(Vector3.ZERO, Vector3.ZERO)


## Returns damage the next level-1 Waxlight hit will apply after runtime upgrades.
func debug_next_hit_damage() -> float:
	return debug_weapon_damage(&"waxlight_comet")


## Returns current weapon damage after runtime upgrades.
func debug_weapon_damage(weapon_id: StringName) -> float:
	var data := _weapon_data(weapon_id)
	if data == null:
		return 0.0
	return _runtime_damage(weapon_id, data)


## Returns level-1 Waxlight cooldown after runtime upgrades.
func debug_cooldown_seconds() -> float:
	var data := _weapon_data(&"waxlight_comet")
	if data == null:
		return 0.0
	return _runtime_cooldown_seconds(&"waxlight_comet", data)


## Returns selected weapon cooldown after runtime upgrades.
func debug_weapon_cooldown_seconds(weapon_id: StringName) -> float:
	var data := _weapon_data(weapon_id)
	if data == null:
		return 0.0
	return _runtime_cooldown_seconds(weapon_id, data)


## Returns current weapon max targeting range after runtime upgrades.
func debug_weapon_range_meters(weapon_id: StringName) -> float:
	var data := _weapon_data(weapon_id)
	if data == null:
		return 0.0
	return _runtime_range_meters(weapon_id, data)


## Fires Waxlight immediately at a target for smoke checks using normal hit logic.
func debug_fire_at(target: Node3D) -> void:
	debug_fire_weapon_at(&"waxlight_comet", target)


## Fires a selected weapon immediately at a target for smoke checks.
func debug_fire_weapon_at(weapon_id: StringName, target: Node3D) -> void:
	_sync_weapon_states()
	var state := _state_for_weapon(weapon_id)
	if state.is_empty():
		var data := _weapon_data(weapon_id)
		if data == null:
			return
		state = {"id": weapon_id, "data": data, "level": _weapon_level(weapon_id), "cooldown": 0.0}
	_fire_weapon_state_at(state, target)


## Refreshes pending cooldown after runtime modifier changes.
func refresh_runtime_modifiers() -> void:
	_sync_weapon_states(true)
	for index in _weapon_states.size():
		var state := _weapon_states[index]
		state["cooldown"] = minf(float(state.get("cooldown", 0.0)), _cooldown_for_state(state))
		_weapon_states[index] = state


## Triggers weapon dash payoffs that are owned and unlocked.
func trigger_dash_payoffs(_start_position: Vector3, _end_position: Vector3) -> void:
	_sync_weapon_states()
	if not _star_dash_unlocked():
		return
	var state := _state_for_weapon(&"star_sticker_swarm")
	if state.is_empty():
		return
	var target := _nearest_living_enemy_for_state(state)
	if target == null:
		return
	_fire_star_sticker_volley(state, target, false)


func _sync_weapon_states(reset_cooldowns: bool = false) -> void:
	var owned_ids := _owned_weapon_ids()
	var next_states: Array[Dictionary] = []
	for weapon_id in owned_ids:
		var data := _weapon_data(weapon_id)
		if data == null:
			continue
		var existing := _state_for_weapon(weapon_id)
		next_states.append({
			"id": weapon_id,
			"data": data,
			"level": _weapon_level(weapon_id),
			"cooldown": 0.0 if reset_cooldowns or existing.is_empty() else float(existing.get("cooldown", 0.0)),
		})
	_weapon_states = next_states
	_sync_star_orbits()


func _owned_weapon_ids() -> Array[StringName]:
	if _upgrade_state != null and _upgrade_state.has_method("owned_weapon_ids"):
		return _upgrade_state.owned_weapon_ids()
	if _fallback_weapon_data != null:
		return [_fallback_weapon_data.id]
	return []


func _weapon_level(weapon_id: StringName) -> int:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_level"):
		return maxi(1, _upgrade_state.weapon_level(weapon_id))
	return 1


func _weapon_data(weapon_id: StringName) -> Resource:
	if _content_factory != null:
		if _content_factory.has_method("weapon_for_id"):
			return _content_factory.weapon_for_id(weapon_id)
	if _fallback_weapon_data != null and _fallback_weapon_data.id == weapon_id:
		return _fallback_weapon_data
	return null


func _state_for_weapon(weapon_id: StringName) -> Dictionary:
	for state in _weapon_states:
		if state.get("id", &"") == weapon_id:
			return state
	return {}


func _nearest_living_enemy_for_state(state: Dictionary) -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := _range_for_state(state)
	if _enemies_root == null:
		return null
	for child in _enemies_root.get_children():
		if not child is Node3D:
			continue
		var health := child.get_node_or_null("HealthComponent")
		if health == null or not health.has_method("is_alive") or not health.is_alive():
			continue
		var distance := _owner.global_position.distance_to((child as Node3D).global_position)
		if distance <= nearest_distance:
			nearest = child
			nearest_distance = distance
	return nearest


func _fire_weapon_state_at(state: Dictionary, target: Node3D) -> void:
	var weapon_id: StringName = state.get("id", &"")
	if weapon_id == &"star_sticker_swarm":
		_fire_star_sticker(state, target)
	elif weapon_id == &"dreamsap_glob":
		_fire_dreamsap_glob(state, target)
	elif weapon_id == &"color_bloom":
		_fire_color_bloom(state, target)
	else:
		_fire_direct_marking_weapon(state, target)


func _fire_direct_marking_weapon(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	for enemy in _counted_targets(target, _direct_marking_target_count(weapon_data.id), _range_for_state(state)):
		_fire_direct_marking_hit(state, enemy)


func _fire_direct_marking_hit(state: Dictionary, target: Node3D) -> void:
	var health := target.get_node_or_null("HealthComponent")
	if health == null:
		return
	var weapon_data: Resource = state["data"]
	var damage := _runtime_damage(weapon_data.id, weapon_data, weapon_data.material_tags)
	_damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
	if weapon_data.id == &"waxlight_comet":
		_create_waxlight_impact_feedback(target.global_position, _runtime_mark_radius(weapon_data.id, weapon_data))
		_apply_waxlight_impact_splat(target, weapon_data, damage, weapon_data.material_tags)
		if _waxlight_marks_unlocked():
			_deposit_pagecraft_mark(target.global_position, weapon_data, damage)
	else:
		_deposit_pagecraft_mark(target.global_position, weapon_data, damage)
	_count_hit(weapon_data.id)


func _fire_star_sticker(state: Dictionary, target: Node3D) -> void:
	_fire_star_sticker_volley(state, target, true)


func _fire_star_sticker_volley(state: Dictionary, target: Node3D, create_nodes: bool) -> void:
	var weapon_data: Resource = state["data"]
	var damage := _runtime_damage(weapon_data.id, weapon_data, weapon_data.material_tags)
	_sync_star_orbits()
	var targets := _sticker_targets(target, _desired_star_orbit_count(), _range_for_state(state))
	for enemy in targets:
		if not _apply_star_damage(enemy, weapon_data.id, damage, weapon_data.material_tags, _owner.global_position):
			continue
		_count_hit(weapon_data.id)
		_fire_star_node_followup(enemy, weapon_data, damage, create_nodes)


func _fire_star_node_followup(enemy: Node3D, weapon_data: Resource, damage: float, create_nodes: bool) -> void:
	if not _star_nodes_unlocked():
		return
	var node: Dictionary = {}
	if create_nodes:
		node = _star_network.add_node(enemy.global_position, _runtime_mark_radius(weapon_data.id, weapon_data), _star_node_cap(), self)
	else:
		if _star_network.node_count() < 2:
			return
		node = _star_network.closest_node(enemy.global_position, INF)
	_fire_star_ricochet_path_from_node(node, weapon_data, damage * STAR_RICOCHET_DAMAGE_SCALE)


func _fire_star_ricochet_path_from_node(node: Dictionary, weapon_data: Resource, ricochet_damage: float) -> void:
	if node.is_empty():
		return
	if _star_network.node_count() < 2:
		return
	var path := _star_network.chain_from_node(node, _star_node_range_meters(weapon_data), _star_l10_unlocked())
	if path.size() < 2:
		return
	for index in range(path.size() - 1):
		var start_node := path[index]
		var end_node := path[index + 1]
		_fire_star_ricochet_segment(start_node, end_node, weapon_data, ricochet_damage)


func _fire_star_ricochet_segment(start_node: Dictionary, end_node: Dictionary, weapon_data: Resource, ricochet_damage: float) -> void:
	var start_position: Vector3 = start_node.get("position", Vector3.ZERO)
	var end_position: Vector3 = end_node.get("position", Vector3.ZERO)
	_star_ricochet_segment_count += 1
	_track_transient_entries(_star_network.create_constellation_feedback(start_node, end_node, self, STAR_CONSTELLATION_FEEDBACK_SECONDS, _star_ricochet_segment_count))
	var enemies := _star_network.enemies_along_segment(start_position, end_position, _enemies_root, STAR_RICOCHET_HIT_WIDTH_METERS)
	for enemy in enemies:
		if _apply_star_damage(enemy, &"star_sticker_swarm_ricochet", ricochet_damage, weapon_data.material_tags, start_position, false):
			_star_ricochet_damage_count += 1
			_count_hit(weapon_data.id)


func _apply_star_damage(enemy: Node3D, source_id: StringName, damage: float, damage_tags: Array, start_position: Vector3, create_travel_feedback: bool = true) -> bool:
	var health := enemy.get_node_or_null("HealthComponent")
	if health == null:
		return false
	var result: Dictionary = _damage_model.apply_damage(health, source_id, damage, damage_tags)
	if result.is_empty():
		return false
	if create_travel_feedback:
		_create_star_travel_feedback(start_position, enemy.global_position)
	return true


func _fire_dreamsap_glob(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	var damage := _runtime_damage(weapon_data.id, weapon_data, weapon_data.material_tags)
	var result: Dictionary = MvpWeaponEffectsScript.fire_dreamsap_glob(self, _enemies_root, _damage_model, weapon_data, _runtime_mark_radius(weapon_data.id, weapon_data), target, damage)
	_deposit_pagecraft_mark(target.global_position, weapon_data, damage)
	_count_hits(weapon_data.id, int(result.get("hits", 0)))
	_track_transient_entries(result.get("transients", []))


func _fire_color_bloom(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	var damage := _runtime_damage(weapon_data.id, weapon_data, weapon_data.material_tags)
	var result: Dictionary = MvpWeaponEffectsScript.fire_color_bloom(self, _enemies_root, _damage_model, weapon_data, _runtime_mark_radius(weapon_data.id, weapon_data), target, damage)
	_deposit_pagecraft_mark(target.global_position, weapon_data, damage)
	_count_hits(weapon_data.id, int(result.get("hits", 0)))
	_track_transient_entries(result.get("transients", []))


func _sticker_targets(primary: Node3D, max_count: int, range_meters: float) -> Array[Node3D]:
	return _counted_targets(primary, max_count, range_meters)


func _counted_targets(primary: Node3D, max_count: int, range_meters: float) -> Array[Node3D]:
	var targets: Array[Node3D] = []
	if max_count <= 0:
		return targets
	if _is_living_enemy(primary):
		targets.append(primary)
	if _enemies_root == null:
		return targets
	for child in _enemies_root.get_children():
		if targets.size() >= max_count:
			break
		if child == primary or not child is Node3D:
			continue
		if _is_living_enemy(child as Node3D) and _is_inside_owner_range(child as Node3D, range_meters):
			targets.append(child)
	return targets


func _direct_marking_target_count(weapon_id: StringName) -> int:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_projectile_count"):
		return _upgrade_state.weapon_projectile_count(weapon_id, 1)
	return 1


func _is_living_enemy(candidate: Node3D) -> bool:
	if candidate == null:
		return false
	var health := candidate.get_node_or_null("HealthComponent")
	return health != null and health.has_method("is_alive") and health.is_alive()


func _is_inside_owner_range(candidate: Node3D, range_meters: float) -> bool:
	return _owner != null and candidate != null and _owner.global_position.distance_to(candidate.global_position) <= range_meters


func _deposit_pagecraft_mark(weapon_position: Vector3, weapon_data: Resource, activation_damage: float) -> void:
	if _pagecraft_manager == null or not _pagecraft_manager.has_method("deposit_mark"):
		return
	_pagecraft_manager.deposit_mark(
		weapon_position,
		weapon_data.pagecraft_material_tag,
		weapon_data.base_mark_radius_meters,
		weapon_data.id,
		activation_damage,
		weapon_data.material_tags
	)


func _create_star_travel_feedback(start_position: Vector3, end_position: Vector3) -> void:
	var start_flat := Vector3(start_position.x, 0.72, start_position.z)
	var end_flat := Vector3(end_position.x, 0.72, end_position.z)
	var direction := end_flat - start_flat
	var length := direction.length()
	if length <= 0.01:
		return
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerTravel"
	visual.top_level = true
	var mesh := BoxMesh.new()
	mesh.size = Vector3(length, 0.045, 0.045)
	visual.mesh = mesh
	visual.material_override = _star_material(Color(1.0, 0.94, 0.25, 0.9), 0.9)
	add_child(visual)
	visual.global_position = start_flat + direction * 0.5
	var normalized := direction.normalized()
	visual.rotation.y = atan2(-normalized.z, normalized.x)
	_track_transient_visual(visual, STAR_TRAVEL_FEEDBACK_SECONDS)


func _create_waxlight_impact_feedback(world_position: Vector3, radius: float) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "WaxlightAttackVisual"
	visual.top_level = true
	var mesh := CylinderMesh.new()
	var feedback_radius := maxf(0.35, radius)
	mesh.top_radius = feedback_radius
	mesh.bottom_radius = feedback_radius
	mesh.height = 0.045
	mesh.radial_segments = 32
	visual.mesh = mesh
	visual.material_override = _waxlight_material(Color(1.0, 0.7, 0.16, 0.58), 0.85)
	add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.11, world_position.z)
	_track_transient_visual(visual, WAXLIGHT_IMPACT_FEEDBACK_SECONDS)


func _star_material(color: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_multiplier
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _waxlight_material(color: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_multiplier
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _sync_star_orbits() -> void:
	var desired_count := _desired_star_orbit_count()
	while _star_orbit_visuals.size() < desired_count:
		var visual := _create_star_orbit_visual(_star_orbit_visuals.size())
		_star_orbit_visuals.append(visual)
	while _star_orbit_visuals.size() > desired_count:
		var visual: MeshInstance3D = _star_orbit_visuals.pop_back()
		if visual != null:
			visual.queue_free()
	for index in _star_orbit_visuals.size():
		_star_orbit_visuals[index].visible = true


func _desired_star_orbit_count() -> int:
	if not _owned_weapon_ids().has(&"star_sticker_swarm"):
		return 0
	var base_count := 1
	if _upgrade_state != null and _upgrade_state.has_method("weapon_projectile_count"):
		return _upgrade_state.weapon_projectile_count(&"star_sticker_swarm", base_count)
	return base_count


func _create_star_orbit_visual(index: int) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerOrbit_%d" % index
	visual.top_level = true
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.34, 0.08, 0.34)
	visual.mesh = mesh
	visual.material_override = _star_material(Color(1.0, 0.95, 0.25, 0.95), 0.65)
	add_child(visual)
	return visual


func _update_star_orbits() -> void:
	if _owner == null:
		return
	var count: int = max(1, _star_orbit_visuals.size())
	for index in _star_orbit_visuals.size():
		var angle := _star_orbit_angle + TAU * float(index) / float(count)
		var offset := Vector3(cos(angle), 0.0, sin(angle)) * 0.95
		_star_orbit_visuals[index].global_position = _owner.global_position + offset + Vector3(0.0, 0.8, 0.0)


func _track_transient_visual(visual: Node, lifetime_seconds: float) -> void:
	_transient_visuals.append({
		"visual": visual,
		"remaining": lifetime_seconds,
	})


func _track_transient_entries(entries: Array) -> void:
	for entry in entries:
		if entry is Dictionary and not (entry as Dictionary).is_empty():
			_transient_visuals.append(entry)


func _tick_transient_visuals(delta: float) -> void:
	for index in range(_transient_visuals.size() - 1, -1, -1):
		var entry := _transient_visuals[index]
		entry["remaining"] = float(entry.get("remaining", 0.0)) - delta
		if float(entry["remaining"]) <= 0.0:
			var visual = entry.get("visual", null)
			if visual is Node:
				(visual as Node).queue_free()
			_transient_visuals.remove_at(index)
			continue
		_transient_visuals[index] = entry


func _runtime_damage(weapon_id: StringName, weapon_data: Resource, damage_tags: Array = []) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_damage"):
		return _upgrade_state.weapon_damage(weapon_id, weapon_data.base_damage, damage_tags)
	if _upgrade_state != null and _upgrade_state.has_method("damage_for_tags"):
		return _upgrade_state.damage_for_tags(weapon_id, weapon_data.base_damage, damage_tags)
	return weapon_data.base_damage


func _runtime_cooldown_seconds(weapon_id: StringName, weapon_data: Resource) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_cooldown_seconds"):
		return _upgrade_state.weapon_cooldown_seconds(weapon_id, weapon_data.base_cooldown_seconds)
	return weapon_data.base_cooldown_seconds


func _range_for_state(state: Dictionary) -> float:
	var weapon_data: Resource = state.get("data", null)
	if weapon_data == null:
		return target_range
	return _runtime_range_meters(weapon_data.id, weapon_data)


func _runtime_range_meters(weapon_id: StringName, weapon_data: Resource) -> float:
	var base_range := target_range
	if weapon_data != null and "base_range_meters" in weapon_data:
		base_range = float(weapon_data.base_range_meters)
	if _upgrade_state != null and _upgrade_state.has_method("weapon_range_meters"):
		return _upgrade_state.weapon_range_meters(weapon_id, base_range)
	return base_range


func _cooldown_for_state(state: Dictionary) -> float:
	var weapon_data: Resource = state["data"]
	return _runtime_cooldown_seconds(weapon_data.id, weapon_data)


func _runtime_mark_radius(weapon_id: StringName, weapon_data: Resource) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_mark_radius_meters"):
		return _upgrade_state.weapon_mark_radius_meters(weapon_id, weapon_data.base_mark_radius_meters)
	return weapon_data.base_mark_radius_meters


func _star_nodes_unlocked() -> bool:
	if _upgrade_state != null and _upgrade_state.has_method("star_sticker_nodes_unlocked"):
		return _upgrade_state.star_sticker_nodes_unlocked()
	return _weapon_level(&"star_sticker_swarm") >= 5


func _star_l10_unlocked() -> bool:
	if _upgrade_state != null and _upgrade_state.has_method("star_sticker_l10_unlocked"):
		return _upgrade_state.star_sticker_l10_unlocked()
	return _weapon_level(&"star_sticker_swarm") >= 10


func _star_dash_unlocked() -> bool:
	if _upgrade_state != null and _upgrade_state.has_method("star_sticker_dash_unlocked"):
		return _upgrade_state.star_sticker_dash_unlocked()
	return _star_nodes_unlocked()


func _waxlight_marks_unlocked() -> bool:
	if _upgrade_state != null and _upgrade_state.has_method("waxlight_dash_unlocked"):
		return _upgrade_state.waxlight_dash_unlocked()
	return _weapon_level(&"waxlight_comet") >= 5


func _star_node_cap() -> int:
	if _upgrade_state != null and _upgrade_state.has_method("star_sticker_node_cap"):
		return _upgrade_state.star_sticker_node_cap(BASE_STAR_NODE_CAP)
	return BASE_STAR_NODE_CAP


func _star_node_range_meters(weapon_data: Resource = null) -> float:
	var data := weapon_data
	if data == null:
		data = _weapon_data(&"star_sticker_swarm")
	if data != null:
		return _runtime_range_meters(&"star_sticker_swarm", data)
	return target_range


func _apply_waxlight_impact_splat(target: Node3D, weapon_data: Resource, damage: float, damage_tags: Array) -> void:
	if _enemies_root == null:
		return
	var radius := maxf(0.5, _runtime_mark_radius(weapon_data.id, weapon_data) * 1.6)
	var splat_damage := maxf(1.0, damage)
	for enemy in _enemies_root.get_children():
		if enemy == target or not enemy is Node3D or not _is_living_enemy(enemy as Node3D):
			continue
		if (enemy as Node3D).global_position.distance_to(target.global_position) > radius:
			continue
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null:
			continue
		var result: Dictionary = _damage_model.apply_damage(health, &"waxlight_comet_impact_splat", splat_damage, damage_tags)
		if not result.is_empty():
			_count_hit(&"waxlight_comet")


func _count_hit(weapon_id: StringName) -> void:
	_hit_counts[weapon_id] = int(_hit_counts.get(weapon_id, 0)) + 1


func _count_hits(weapon_id: StringName, amount: int) -> void:
	for _index in maxi(0, amount):
		_count_hit(weapon_id)
