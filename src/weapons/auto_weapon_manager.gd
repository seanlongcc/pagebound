class_name AutoWeaponManager
extends Node

const MvpWeaponEffectsScript := preload("res://src/weapons/mvp_weapon_effects.gd")
const STAR_STICKER_LIFETIME_SECONDS := 1.25
const STAR_STICKER_POP_DAMAGE_SCALE := 0.75
const STAR_STICKER_POP_RADIUS_SCALE := 2.0
const STAR_TRAVEL_FEEDBACK_SECONDS := 0.22
const STAR_POP_FEEDBACK_SECONDS := 0.35
const MAX_STAR_STICKER_COUNT := 4

@export_range(0.0, 40.0, 0.1) var target_range := 12.0

var _owner: Node3D
var _enemies_root: Node
var _damage_model
var _pagecraft_manager: Node
var _upgrade_state
var _content_factory
var _fallback_weapon_data: Resource
var _weapon_states: Array[Dictionary] = []
var _hit_counts: Dictionary = {}
var _star_page_stickers: Array[Dictionary] = []
var _star_orbit_visuals: Array[MeshInstance3D] = []
var _star_orbit_available: Array[bool] = []
var _star_orbit_angle := 0.0
var _star_pop_damage_count := 0
var _transient_visuals: Array[Dictionary] = []


func _physics_process(delta: float) -> void:
	_tick_star_page_stickers(delta)
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
	var count := 0
	for available in _star_orbit_available:
		if available:
			count += 1
	return count


## Returns active page-stuck Star Sticker count.
func debug_star_page_sticker_count() -> int:
	return _star_page_stickers.size()


## Returns the number of enemies damaged by Star Sticker pops.
func debug_star_pop_damage_count() -> int:
	return _star_pop_damage_count


## Returns damage the next level-1 Waxlight hit will apply after runtime upgrades.
func debug_next_hit_damage() -> float:
	return debug_weapon_damage(&"waxlight_comet")


## Returns current weapon damage after runtime upgrades.
func debug_weapon_damage(weapon_id: StringName) -> float:
	var data := _weapon_data(weapon_id)
	if data == null:
		return 0.0
	return _runtime_damage(weapon_id, data.level_data_for(_weapon_level(weapon_id)))


## Returns level-1 Waxlight cooldown after runtime upgrades.
func debug_cooldown_seconds() -> float:
	var data := _weapon_data(&"waxlight_comet")
	if data == null:
		return 0.0
	return _runtime_cooldown_seconds(&"waxlight_comet", data.level_data_for(_weapon_level(&"waxlight_comet")))


## Returns current weapon max targeting range after runtime upgrades.
func debug_weapon_range_meters(weapon_id: StringName) -> float:
	var data := _weapon_data(weapon_id)
	if data == null:
		return 0.0
	return _runtime_range_meters(weapon_id, data.level_data_for(_weapon_level(weapon_id)))


## Fires Waxlight immediately at a target for smoke checks using normal hit logic.
func debug_fire_at(target: Node3D) -> void:
	debug_fire_weapon_at(&"waxlight_comet", target)


## Fires a selected weapon immediately at a target for smoke checks.
func debug_fire_weapon_at(weapon_id: StringName, target: Node3D) -> void:
	_sync_weapon_states()
	if weapon_id == &"star_sticker_swarm":
		_sync_star_orbits()
		if debug_star_available_count() == 0 and not _star_orbit_available.is_empty():
			_release_star_orbit(0)
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
	var health := target.get_node_or_null("HealthComponent")
	if health == null:
		return
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	var damage := _runtime_damage(weapon_data.id, level_data, weapon_data.material_tags)
	_damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
	_deposit_pagecraft_mark(target.global_position, weapon_data, level_data, damage)
	_count_hit(weapon_data.id)


func _fire_star_sticker(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	var damage := _runtime_damage(weapon_data.id, level_data, weapon_data.material_tags)
	_sync_star_orbits()
	var targets := _sticker_targets(target, debug_star_available_count(), _range_for_state(state))
	for enemy in targets:
		var orbit_index := _claim_star_orbit()
		if orbit_index < 0:
			return
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null:
			_release_star_orbit(orbit_index)
			continue
		_damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
		_create_star_travel_feedback(_owner.global_position, enemy.global_position)
		_create_star_page_sticker(enemy.global_position, weapon_data, level_data, damage, orbit_index)
		_count_hit(weapon_data.id)


func _fire_dreamsap_glob(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	var damage := _runtime_damage(weapon_data.id, level_data, weapon_data.material_tags)
	var result: Dictionary = MvpWeaponEffectsScript.fire_dreamsap_glob(self, _enemies_root, _damage_model, weapon_data, level_data, target, damage)
	_deposit_pagecraft_mark(target.global_position, weapon_data, level_data, damage)
	_count_hits(weapon_data.id, int(result.get("hits", 0)))
	_track_transient_entries(result.get("transients", []))


func _fire_color_bloom(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	var damage := _runtime_damage(weapon_data.id, level_data, weapon_data.material_tags)
	var result: Dictionary = MvpWeaponEffectsScript.fire_color_bloom(self, _enemies_root, _damage_model, weapon_data, level_data, target, damage)
	_deposit_pagecraft_mark(target.global_position, weapon_data, level_data, damage)
	_count_hits(weapon_data.id, int(result.get("hits", 0)))
	_track_transient_entries(result.get("transients", []))


func _sticker_targets(primary: Node3D, max_count: int, range_meters: float) -> Array[Node3D]:
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


func _is_living_enemy(candidate: Node3D) -> bool:
	if candidate == null:
		return false
	var health := candidate.get_node_or_null("HealthComponent")
	return health != null and health.has_method("is_alive") and health.is_alive()


func _is_inside_owner_range(candidate: Node3D, range_meters: float) -> bool:
	return _owner != null and candidate != null and _owner.global_position.distance_to(candidate.global_position) <= range_meters


func _deposit_pagecraft_mark(weapon_position: Vector3, weapon_data: Resource, level_data: Resource, activation_damage: float) -> void:
	if _pagecraft_manager == null or not _pagecraft_manager.has_method("deposit_mark"):
		return
	_pagecraft_manager.deposit_mark(
		weapon_position,
		weapon_data.pagecraft_material_tag,
		level_data.mark_radius_meters,
		weapon_data.id,
		activation_damage,
		weapon_data.material_tags
	)


func _create_star_page_sticker(world_position: Vector3, weapon_data: Resource, level_data: Resource, hit_damage: float, orbit_index: int) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerPageSticker_%d" % _star_page_stickers.size()
	visual.top_level = true
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.46, 0.06, 0.46)
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.92, 0.18, 0.95)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.72, 0.12, 1.0)
	material.emission_energy_multiplier = 0.75
	visual.material_override = material
	add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.08, world_position.z)
	_star_page_stickers.append({
		"position": visual.global_position,
		"radius": maxf(0.55, float(level_data.mark_radius_meters) * STAR_STICKER_POP_RADIUS_SCALE),
		"damage": maxf(1.0, hit_damage * STAR_STICKER_POP_DAMAGE_SCALE),
		"damage_tags": _string_name_array(weapon_data.material_tags),
		"remaining": STAR_STICKER_LIFETIME_SECONDS,
		"visual": visual,
		"orbit_index": orbit_index,
	})


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


func _create_star_pop_feedback(world_position: Vector3, radius: float) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerPop"
	visual.top_level = true
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.045
	mesh.radial_segments = 12
	visual.mesh = mesh
	visual.material_override = _star_material(Color(1.0, 0.58, 0.12, 0.45), 1.2)
	add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.1, world_position.z)
	_track_transient_visual(visual, STAR_POP_FEEDBACK_SECONDS)


func _star_material(color: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_multiplier
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _tick_star_page_stickers(delta: float) -> void:
	for index in range(_star_page_stickers.size() - 1, -1, -1):
		var sticker := _star_page_stickers[index]
		sticker["remaining"] = float(sticker.get("remaining", 0.0)) - delta
		if float(sticker["remaining"]) <= 0.0:
			_pop_star_page_sticker(index)
			continue
		_update_star_page_sticker_visual(sticker)
		_star_page_stickers[index] = sticker


func _pop_star_page_sticker(index: int) -> void:
	if index < 0 or index >= _star_page_stickers.size():
		return
	var sticker := _star_page_stickers[index]
	var position: Vector3 = sticker.get("position", Vector3.ZERO)
	var radius := float(sticker.get("radius", 0.0))
	_create_star_pop_feedback(position, radius)
	_apply_star_pop_damage(sticker)
	var visual = sticker.get("visual", null)
	if visual is Node:
		(visual as Node).queue_free()
	_star_page_stickers.remove_at(index)
	_release_star_orbit(int(sticker.get("orbit_index", -1)))


func _apply_star_pop_damage(sticker: Dictionary) -> void:
	if _damage_model == null or _enemies_root == null:
		return
	var position: Vector3 = sticker.get("position", Vector3.ZERO)
	var radius := float(sticker.get("radius", 0.0))
	var damage := float(sticker.get("damage", 0.0))
	for enemy in _enemies_root.get_children():
		if not enemy is Node3D or not _is_living_enemy(enemy as Node3D):
			continue
		if (enemy as Node3D).global_position.distance_to(position) > radius:
			continue
		var health := enemy.get_node_or_null("HealthComponent")
		var result: Dictionary = _damage_model.apply_damage(
			health,
			&"star_sticker_swarm_page_pop",
			damage,
			sticker.get("damage_tags", [])
		)
		if not result.is_empty():
			_star_pop_damage_count += 1


func _update_star_page_sticker_visual(sticker: Dictionary) -> void:
	var visual = sticker.get("visual", null)
	if not visual is MeshInstance3D:
		return
	var ratio := clampf(float(sticker.get("remaining", 0.0)) / STAR_STICKER_LIFETIME_SECONDS, 0.0, 1.0)
	(visual as MeshInstance3D).scale = Vector3.ONE * lerpf(1.2, 0.75, 1.0 - ratio)


func _sync_star_orbits() -> void:
	var desired_count := _desired_star_orbit_count()
	while _star_orbit_visuals.size() < desired_count:
		var visual := _create_star_orbit_visual(_star_orbit_visuals.size())
		_star_orbit_visuals.append(visual)
		_star_orbit_available.append(true)
	while _star_orbit_visuals.size() > desired_count:
		var visual: MeshInstance3D = _star_orbit_visuals.pop_back()
		if visual != null:
			visual.queue_free()
		_star_orbit_available.pop_back()
	for index in _star_orbit_visuals.size():
		_star_orbit_visuals[index].visible = _star_orbit_available[index]


func _desired_star_orbit_count() -> int:
	if not _owned_weapon_ids().has(&"star_sticker_swarm"):
		return 0
	var base_count := 1
	if _upgrade_state != null and _upgrade_state.has_method("weapon_projectile_count"):
		return _upgrade_state.weapon_projectile_count(&"star_sticker_swarm", base_count)
	return clampi(_weapon_level(&"star_sticker_swarm"), 1, MAX_STAR_STICKER_COUNT)


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


func _claim_star_orbit() -> int:
	for index in _star_orbit_available.size():
		if _star_orbit_available[index]:
			_star_orbit_available[index] = false
			if index < _star_orbit_visuals.size():
				_star_orbit_visuals[index].visible = false
			return index
	return -1


func _release_star_orbit(index: int) -> void:
	if index < 0 or index >= _star_orbit_available.size():
		return
	_star_orbit_available[index] = true
	if index < _star_orbit_visuals.size():
		_star_orbit_visuals[index].visible = true


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


func _runtime_damage(weapon_id: StringName, level_data: Resource, damage_tags: Array = []) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_damage"):
		return _upgrade_state.weapon_damage(weapon_id, level_data.base_damage)
	if _upgrade_state != null and _upgrade_state.has_method("damage_for_tags"):
		return _upgrade_state.damage_for_tags(weapon_id, level_data.base_damage, damage_tags)
	return level_data.base_damage


func _runtime_cooldown_seconds(weapon_id: StringName, level_data: Resource) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_cooldown_seconds"):
		return _upgrade_state.weapon_cooldown_seconds(weapon_id, level_data.cooldown_seconds)
	return level_data.cooldown_seconds


func _range_for_state(state: Dictionary) -> float:
	var weapon_data: Resource = state.get("data", null)
	if weapon_data == null:
		return target_range
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	return _runtime_range_meters(weapon_data.id, level_data)


func _runtime_range_meters(weapon_id: StringName, level_data: Resource) -> float:
	var base_range := target_range
	if level_data != null and "range_meters" in level_data:
		base_range = float(level_data.range_meters)
	if _upgrade_state != null and _upgrade_state.has_method("weapon_range_meters"):
		return _upgrade_state.weapon_range_meters(weapon_id, base_range)
	return base_range


func _cooldown_for_state(state: Dictionary) -> float:
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	return _runtime_cooldown_seconds(weapon_data.id, level_data)


func _count_hit(weapon_id: StringName) -> void:
	_hit_counts[weapon_id] = int(_hit_counts.get(weapon_id, 0)) + 1


func _count_hits(weapon_id: StringName, amount: int) -> void:
	for _index in maxi(0, amount):
		_count_hit(weapon_id)


func _string_name_array(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(value)
	if not result.has(&"page_sticker"):
		result.append(&"page_sticker")
	if not result.has(&"pop"):
		result.append(&"pop")
	return result
