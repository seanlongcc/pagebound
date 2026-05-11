class_name AutoWeaponManager
extends Node

@export_range(0.0, 40.0, 0.1) var target_range := 12.0

var _owner: Node3D
var _enemies_root: Node
var _damage_model
var _pagecraft_manager: Node
var _weapon_data: Resource
var _cooldown_remaining := 0.0
var _hit_count := 0


func _physics_process(delta: float) -> void:
	if _owner == null or _weapon_data == null or _damage_model == null:
		return
	_cooldown_remaining = maxf(0.0, _cooldown_remaining - delta)
	if _cooldown_remaining > 0.0:
		return
	var target := _nearest_living_enemy()
	if target == null:
		return
	_fire_at(target)


## Configures the first playable auto weapon runtime.
func configure(owner: Node3D, enemies_root: Node, damage_model, weapon_data: Resource, pagecraft_manager: Node = null) -> void:
	_owner = owner
	_enemies_root = enemies_root
	_damage_model = damage_model
	_weapon_data = weapon_data
	_pagecraft_manager = pagecraft_manager
	_cooldown_remaining = 0.0


## Returns hit count for smoke/debug checks.
func debug_hit_count() -> int:
	return _hit_count


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


func _fire_at(target: Node3D) -> void:
	var health := target.get_node_or_null("HealthComponent")
	if health == null:
		return
	var level_data = _weapon_data.level_data_for(1)
	_damage_model.apply_damage(health, _weapon_data.id, level_data.base_damage, _weapon_data.material_tags)
	_deposit_pagecraft_mark(target.global_position, level_data)
	_hit_count += 1
	_cooldown_remaining = level_data.cooldown_seconds


func _deposit_pagecraft_mark(world_position: Vector3, level_data: Resource) -> void:
	if _pagecraft_manager == null or not _pagecraft_manager.has_method("deposit_mark"):
		return
	_pagecraft_manager.deposit_mark(world_position, _weapon_data.pagecraft_material_tag, level_data.mark_radius_meters, _weapon_data.id)
