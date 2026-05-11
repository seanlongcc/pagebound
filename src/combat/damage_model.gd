class_name DamageModel
extends RefCounted

var _event_bus: Node


## Injects the runtime event bus used for damage/death facts.
func configure(event_bus: Node) -> void:
	_event_bus = event_bus


## Resolves one damage request against a health component.
func apply_damage(target: Node, source_id: StringName, base_damage: float, damage_tags: Array = []) -> Dictionary:
	if target == null or not target.has_method("apply_resolved_damage"):
		return {}
	if target.has_method("is_alive") and not target.is_alive():
		return {}

	var final_damage := maxf(0.0, base_damage)
	var health_result: Dictionary = target.apply_resolved_damage(final_damage)
	var event := _damage_event(target, source_id, final_damage, damage_tags, health_result)
	_emit_damage_resolved(event)
	if health_result.get("killed", false):
		_emit_entity_died(event)
	return event


func _damage_event(target: Node, source_id: StringName, final_damage: float, damage_tags: Array, health_result: Dictionary) -> Dictionary:
	return {
		"source_id": source_id,
		"target_id": _target_id(target),
		"target": target,
		"amount": final_damage,
		"damage_tags": _string_name_array(damage_tags),
		"previous_health": health_result.get("previous_health", 0.0),
		"current_health": health_result.get("current_health", 0.0),
		"killed": health_result.get("killed", false),
		"world_position": _target_position(target),
	}


func _emit_damage_resolved(event: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_damage_resolved"):
		_event_bus.emit_damage_resolved(event)


func _emit_entity_died(event: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_entity_died"):
		_event_bus.emit_entity_died(event)


func _target_id(target: Node) -> StringName:
	if target != null and "entity_id" in target:
		return target.entity_id
	return &"unknown_target"


func _target_position(target: Node) -> Vector3:
	if target is Node3D:
		return (target as Node3D).global_position
	if target != null and target.get_parent() is Node3D:
		return (target.get_parent() as Node3D).global_position
	return Vector3.ZERO


func _string_name_array(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(value)
	return result
