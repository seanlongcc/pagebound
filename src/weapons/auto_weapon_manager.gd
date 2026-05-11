class_name AutoWeaponManager
extends Node

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


func _physics_process(delta: float) -> void:
	if _owner == null or _damage_model == null:
		return
	_sync_weapon_states()
	for index in _weapon_states.size():
		var state := _weapon_states[index]
		state["cooldown"] = maxf(0.0, float(state.get("cooldown", 0.0)) - delta)
		if float(state["cooldown"]) <= 0.0:
			var target := _nearest_living_enemy()
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


## Fires Waxlight immediately at a target for smoke checks using normal hit logic.
func debug_fire_at(target: Node3D) -> void:
	debug_fire_weapon_at(&"waxlight_comet", target)


## Fires a selected weapon immediately at a target for smoke checks.
func debug_fire_weapon_at(weapon_id: StringName, target: Node3D) -> void:
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
		if weapon_id == &"waxlight_comet" and _content_factory.has_method("waxlight_comet_weapon"):
			return _content_factory.waxlight_comet_weapon()
		if weapon_id == &"star_sticker_swarm" and _content_factory.has_method("star_sticker_swarm_weapon"):
			return _content_factory.star_sticker_swarm_weapon()
	if _fallback_weapon_data != null and _fallback_weapon_data.id == weapon_id:
		return _fallback_weapon_data
	return null


func _state_for_weapon(weapon_id: StringName) -> Dictionary:
	for state in _weapon_states:
		if state.get("id", &"") == weapon_id:
			return state
	return {}


func _nearest_living_enemy() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := target_range
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
	else:
		_fire_direct_marking_weapon(state, target)


func _fire_direct_marking_weapon(state: Dictionary, target: Node3D) -> void:
	var health := target.get_node_or_null("HealthComponent")
	if health == null:
		return
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	var damage := _runtime_damage(weapon_data.id, level_data)
	_damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
	_deposit_pagecraft_mark(target.global_position, weapon_data, level_data, damage)
	_count_hit(weapon_data.id)


func _fire_star_sticker(state: Dictionary, target: Node3D) -> void:
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	var damage := _runtime_damage(weapon_data.id, level_data)
	for enemy in _sticker_targets(target):
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null:
			continue
		_damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
		_deposit_pagecraft_mark(enemy.global_position, weapon_data, level_data, damage * 0.5)
		_create_star_feedback(enemy.global_position)
		_count_hit(weapon_data.id)


func _sticker_targets(primary: Node3D) -> Array[Node3D]:
	var targets: Array[Node3D] = []
	if primary != null:
		targets.append(primary)
	if _enemies_root == null:
		return targets
	for child in _enemies_root.get_children():
		if targets.size() >= 2:
			break
		if child == primary or not child is Node3D:
			continue
		var health := child.get_node_or_null("HealthComponent")
		if health != null and health.has_method("is_alive") and health.is_alive():
			targets.append(child)
	return targets


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


func _create_star_feedback(world_position: Vector3) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerHit"
	visual.top_level = true
	var mesh := PrismMesh.new()
	mesh.size = Vector3(0.38, 0.08, 0.38)
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.92, 0.18, 0.95)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.72, 0.12, 1.0)
	material.emission_energy_multiplier = 0.55
	visual.material_override = material
	add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.7, world_position.z)


func _runtime_damage(weapon_id: StringName, level_data: Resource) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_damage"):
		return _upgrade_state.weapon_damage(weapon_id, level_data.base_damage)
	return level_data.base_damage


func _runtime_cooldown_seconds(weapon_id: StringName, level_data: Resource) -> float:
	if _upgrade_state != null and _upgrade_state.has_method("weapon_cooldown_seconds"):
		return _upgrade_state.weapon_cooldown_seconds(weapon_id, level_data.cooldown_seconds)
	return level_data.cooldown_seconds


func _cooldown_for_state(state: Dictionary) -> float:
	var weapon_data: Resource = state["data"]
	var level_data = weapon_data.level_data_for(int(state.get("level", 1)))
	return _runtime_cooldown_seconds(weapon_data.id, level_data)


func _count_hit(weapon_id: StringName) -> void:
	_hit_counts[weapon_id] = int(_hit_counts.get(weapon_id, 0)) + 1
