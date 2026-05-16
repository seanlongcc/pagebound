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


func chain_from_node(start_node: Dictionary, max_range: float, chain_all_nodes: bool) -> Array[Dictionary]:
	var path: Array[Dictionary] = []
	if start_node.is_empty() or not _has_node(start_node):
		return path
	path.append(start_node)
	if _nodes.size() < 2:
		return path

	var unused: Array[Dictionary] = []
	var start_sequence := _node_sequence(start_node)
	for node in _nodes:
		if _node_sequence(node) != start_sequence:
			unused.append(node)

	var current := start_node
	while not unused.is_empty():
		var next_index := _nearest_unused_index(current, unused, max_range if not chain_all_nodes else INF)
		if next_index < 0:
			break
		var next_node := unused[next_index]
		path.append(next_node)
		unused.remove_at(next_index)
		current = next_node
		if not chain_all_nodes:
			break
	return path


func enemies_along_segment(start_position: Vector3, end_position: Vector3, enemies_root: Node, hit_width_meters: float) -> Array[Node3D]:
	var enemies: Array[Node3D] = []
	if enemies_root == null:
		return enemies
	var start_xz := Vector2(start_position.x, start_position.z)
	var end_xz := Vector2(end_position.x, end_position.z)
	var segment := end_xz - start_xz
	var length_squared := segment.length_squared()
	if length_squared <= 0.0001:
		return enemies
	var half_width := maxf(0.0, hit_width_meters * 0.5)
	for child in enemies_root.get_children():
		if not child is Node3D:
			continue
		var enemy := child as Node3D
		if not _is_living_enemy(enemy):
			continue
		var point := Vector2(enemy.global_position.x, enemy.global_position.z)
		var projection := clampf((point - start_xz).dot(segment) / length_squared, 0.0, 1.0)
		var closest_point := start_xz + segment * projection
		if point.distance_to(closest_point) <= half_width:
			enemies.append(enemy)
	return enemies


func create_constellation_feedback(start_node: Dictionary, end_node: Dictionary, parent: Node, lifetime_seconds: float, segment_index: int) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if parent == null:
		return entries
	var start_position: Vector3 = start_node.get("position", Vector3.ZERO)
	var end_position: Vector3 = end_node.get("position", Vector3.ZERO)
	_append_constellation_line(entries, parent, start_position, end_position, lifetime_seconds, segment_index)
	_append_node_pulse(entries, parent, start_position, lifetime_seconds, segment_index, 0)
	_append_node_pulse(entries, parent, end_position, lifetime_seconds, segment_index, 1)
	return entries


func _enforce_cap(cap: int) -> void:
	while _nodes.size() > cap:
		_remove_node_at(0)


func _has_node(node: Dictionary) -> bool:
	var sequence := _node_sequence(node)
	for candidate in _nodes:
		if _node_sequence(candidate) == sequence:
			return true
	return false


func _nearest_unused_index(from_node: Dictionary, candidates: Array[Dictionary], max_range: float) -> int:
	var from_position: Vector3 = from_node.get("position", Vector3.ZERO)
	var nearest_index := -1
	var nearest_distance := max_range
	for index in candidates.size():
		var candidate := candidates[index]
		var candidate_position: Vector3 = candidate.get("position", Vector3.ZERO)
		var distance := from_position.distance_to(candidate_position)
		if distance <= nearest_distance:
			nearest_index = index
			nearest_distance = distance
	return nearest_index


func _node_sequence(node: Dictionary) -> int:
	return int(node.get("sequence", -1))


func _append_constellation_line(entries: Array[Dictionary], parent: Node, start_position: Vector3, end_position: Vector3, lifetime_seconds: float, segment_index: int) -> void:
	var start_flat := Vector3(start_position.x, 0.76, start_position.z)
	var end_flat := Vector3(end_position.x, 0.76, end_position.z)
	var direction := end_flat - start_flat
	var length := direction.length()
	if length <= 0.01:
		return
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerConstellationLine_%d" % segment_index
	visual.top_level = true
	var mesh := BoxMesh.new()
	mesh.size = Vector3(length, 0.038, 0.07)
	visual.mesh = mesh
	visual.material_override = _feedback_material(Color(0.92, 0.98, 1.0, 0.82), 1.15)
	parent.add_child(visual)
	visual.global_position = start_flat + direction * 0.5
	var normalized := direction.normalized()
	visual.rotation.y = atan2(-normalized.z, normalized.x)
	entries.append({"visual": visual, "remaining": lifetime_seconds})


func _append_node_pulse(entries: Array[Dictionary], parent: Node, world_position: Vector3, lifetime_seconds: float, segment_index: int, pulse_index: int) -> void:
	var visual := MeshInstance3D.new()
	visual.name = "StarStickerNodePulse_%d_%d" % [segment_index, pulse_index]
	visual.top_level = true
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.34
	mesh.bottom_radius = 0.34
	mesh.height = 0.035
	mesh.radial_segments = 24
	visual.mesh = mesh
	visual.material_override = _feedback_material(Color(1.0, 0.96, 0.28, 0.7), 1.25)
	parent.add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.14, world_position.z)
	entries.append({"visual": visual, "remaining": lifetime_seconds})


func _feedback_material(color: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_multiplier
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


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
