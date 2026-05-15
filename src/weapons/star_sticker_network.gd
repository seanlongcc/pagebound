class_name StarStickerNetwork
extends RefCounted

var _nodes: Array[Dictionary] = []
var _sequence := 0


func clear() -> void:
	for node in _nodes:
		var visual = node.get("visual", null)
		if visual is Node:
			(visual as Node).queue_free()
	_nodes.clear()


func node_count() -> int:
	return _nodes.size()


func add_node(world_position: Vector3, radius: float, cap: int, parent: Node) -> Dictionary:
	if parent == null:
		return {}
	var visual := _create_node_visual(world_position, radius)
	parent.add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.08, world_position.z)
	var node := {
		"position": visual.global_position,
		"radius": radius,
		"visual": visual,
		"sequence": _sequence,
	}
	_sequence += 1
	_nodes.append(node)
	_enforce_cap(maxi(1, cap))
	return node


func closest_node(world_position: Vector3, max_range: float) -> Dictionary:
	var closest := {}
	var closest_distance := max_range
	for node in _nodes:
		var position: Vector3 = node.get("position", Vector3.ZERO)
		var distance := position.distance_to(world_position)
		if distance <= closest_distance:
			closest = node
			closest_distance = distance
	return closest


func target_from_node(node: Dictionary, enemies_root: Node, excluded: Array, max_range: float) -> Node3D:
	if node.is_empty() or enemies_root == null:
		return null
	var position: Vector3 = node.get("position", Vector3.ZERO)
	var nearest: Node3D = null
	var nearest_distance := max_range
	for child in enemies_root.get_children():
		if not child is Node3D or excluded.has(child):
			continue
		var enemy := child as Node3D
		if not _is_living_enemy(enemy):
			continue
		var distance := enemy.global_position.distance_to(position)
		if distance <= nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func _enforce_cap(cap: int) -> void:
	while _nodes.size() > cap:
		_remove_node_at(0)


func _remove_node_at(index: int) -> void:
	if index < 0 or index >= _nodes.size():
		return
	var node := _nodes[index]
	var visual = node.get("visual", null)
	if visual is Node:
		(visual as Node).queue_free()
	_nodes.remove_at(index)


func _create_node_visual(world_position: Vector3, radius: float) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerNode_%d" % _sequence
	visual.top_level = true
	var mesh := PrismMesh.new()
	mesh.size = Vector3(maxf(0.34, radius * 0.72), 0.06, maxf(0.34, radius * 0.72))
	visual.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.92, 0.18, 0.95)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.72, 0.12, 1.0)
	material.emission_energy_multiplier = 0.75
	visual.material_override = material
	return visual


func _is_living_enemy(candidate: Node3D) -> bool:
	if candidate == null or not candidate.visible:
		return false
	var health := candidate.get_node_or_null("HealthComponent")
	return health != null and health.has_method("is_alive") and health.is_alive()
