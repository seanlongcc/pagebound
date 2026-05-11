class_name PagecraftManager
extends Node

@export_range(0.05, 2.0, 0.05) var dash_activation_padding := 0.45

var _event_bus: Node
var _pagecraft_root: Node3D
var _damage_model
var _enemies_root: Node
var _marks: Array[Dictionary] = []
var _activation_count := 0
var _activation_damage_count := 0
var _last_activation_damage := 0.0
var _pulse_count := 0


## Configures the Pagecraft manager root and event output.
func configure(event_bus: Node, pagecraft_root: Node3D, damage_model = null, enemies_root: Node = null) -> void:
	_event_bus = event_bus
	_pagecraft_root = pagecraft_root
	_damage_model = damage_model
	_enemies_root = enemies_root


## Deposits a visible primitive mark on the page.
func deposit_mark(
	world_position: Vector3,
	material_tag: StringName,
	radius: float,
	source_id: StringName,
	activation_damage: float = 0.0,
	damage_tags: Array = []
) -> void:
	var mark_visual := _create_mark_visual(world_position, radius, false)
	var mark := {
		"position": Vector3(world_position.x, 0.04, world_position.z),
		"radius": radius,
		"material_tag": material_tag,
		"source_id": source_id,
		"activation_damage": activation_damage,
		"damage_tags": _activation_damage_tags(damage_tags),
		"visual": mark_visual,
		"activated": false,
	}
	_marks.append(mark)
	_emit_deposited(mark)


## Activates marks crossed by a dash path.
func activate_path(start_position: Vector3, end_position: Vector3) -> void:
	for index in _marks.size():
		var mark := _marks[index]
		if mark.get("activated", false):
			continue
		if _distance_to_segment(mark["position"], start_position, end_position) <= float(mark["radius"]) + dash_activation_padding:
			_activate_mark(index, start_position, end_position)


## Returns active mark count for smoke/debug checks.
func debug_mark_count() -> int:
	return _marks.size()


## Returns activation count for smoke/debug checks.
func debug_activation_count() -> int:
	return _activation_count


## Returns the number of enemies damaged by dash-activated marks.
func debug_activation_damage_count() -> int:
	return _activation_damage_count


## Returns the last dash activation damage amount for smoke/debug checks.
func debug_last_activation_damage() -> float:
	return _last_activation_damage


## Returns primitive pulse visual count for smoke/debug checks.
func debug_pulse_count() -> int:
	return _pulse_count


## Returns the first mark position for smoke/debug checks.
func debug_first_mark_position() -> Vector3:
	if _marks.is_empty():
		return Vector3.ZERO
	return _marks[0]["position"]


func _activate_mark(index: int, start_position: Vector3, end_position: Vector3) -> void:
	var mark := _marks[index]
	mark["activated"] = true
	_marks[index] = mark
	_activation_count += 1
	var visual = mark.get("visual", null)
	if visual is MeshInstance3D:
		(visual as MeshInstance3D).material_override = _mark_material(true)
		(visual as MeshInstance3D).scale *= 1.35
	_create_dash_pulse(start_position, end_position)
	_apply_activation_damage(mark)
	_emit_activated(mark)


func _create_mark_visual(world_position: Vector3, radius: float, activated: bool) -> MeshInstance3D:
	var visual := MeshInstance3D.new()
	visual.name = "PagecraftMark"
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.035
	mesh.radial_segments = 32
	visual.mesh = mesh
	visual.position = Vector3(world_position.x, 0.03, world_position.z)
	visual.material_override = _mark_material(activated)
	_pagecraft_root.add_child(visual)
	return visual


func _mark_material(activated: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.45, 0.12, 0.9) if activated else Color(1.0, 0.82, 0.18, 0.72)
	material.roughness = 0.7
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _create_dash_pulse(start_position: Vector3, end_position: Vector3) -> void:
	if _pagecraft_root == null:
		return
	var start_flat := Vector3(start_position.x, 0.09, start_position.z)
	var end_flat := Vector3(end_position.x, 0.09, end_position.z)
	var direction := end_flat - start_flat
	var length := direction.length()
	if length <= 0.01:
		return
	var midpoint := start_flat + direction * 0.5
	var normalized_direction := direction.normalized()
	var side := Vector3(-normalized_direction.z, 0.0, normalized_direction.x)
	var pulse_colors := [
		Color(1.0, 0.18, 0.32, 0.92),
		Color(1.0, 0.86, 0.16, 0.92),
		Color(0.2, 0.82, 1.0, 0.92),
	]
	for lane in pulse_colors.size():
		var visual := MeshInstance3D.new()
		visual.name = "WaxlightDashPulse_%d" % _pulse_count
		var mesh := BoxMesh.new()
		mesh.size = Vector3(length, 0.035, 0.055)
		visual.mesh = mesh
		visual.position = midpoint + side * (float(lane) - 1.0) * 0.11
		visual.rotation.y = atan2(-normalized_direction.z, normalized_direction.x)
		visual.material_override = _pulse_material(pulse_colors[lane])
		_pagecraft_root.add_child(visual)
		_pulse_count += 1


func _pulse_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = 0.65
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _apply_activation_damage(mark: Dictionary) -> void:
	if _damage_model == null or _enemies_root == null:
		return
	var activation_damage := float(mark.get("activation_damage", 0.0))
	if activation_damage <= 0.0:
		return
	var radius := float(mark.get("radius", 0.0)) + dash_activation_padding
	for enemy in _enemies_root.get_children():
		if not enemy is Node3D or not (enemy as Node3D).visible:
			continue
		if (enemy as Node3D).global_position.distance_to(mark["position"]) > radius:
			continue
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null:
			continue
		var result: Dictionary = _damage_model.apply_damage(
			health,
			_activation_source_id(mark),
			activation_damage,
			mark.get("damage_tags", [])
		)
		if result.is_empty():
			continue
		_activation_damage_count += 1
		_last_activation_damage = float(result.get("amount", activation_damage))


func _activation_source_id(mark: Dictionary) -> StringName:
	return StringName("%s_dash_activation" % String(mark.get("source_id", &"pagecraft")))


func _activation_damage_tags(base_tags: Array) -> Array[StringName]:
	var tags: Array[StringName] = []
	for tag in base_tags:
		tags.append(tag)
	if not tags.has(&"pagecraft"):
		tags.append(&"pagecraft")
	if not tags.has(&"dash_activation"):
		tags.append(&"dash_activation")
	return tags


func _distance_to_segment(point: Vector3, start_position: Vector3, end_position: Vector3) -> float:
	var start_flat := Vector3(start_position.x, point.y, start_position.z)
	var end_flat := Vector3(end_position.x, point.y, end_position.z)
	var segment := end_flat - start_flat
	var segment_length_squared := segment.length_squared()
	if segment_length_squared == 0.0:
		return point.distance_to(start_flat)
	var t := clampf((point - start_flat).dot(segment) / segment_length_squared, 0.0, 1.0)
	var closest := start_flat + segment * t
	return point.distance_to(closest)


func _emit_deposited(mark: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_pagecraft_mark_deposited"):
		_event_bus.emit_pagecraft_mark_deposited({
			"material_tag": mark["material_tag"],
			"source_id": mark["source_id"],
			"world_position": mark["position"],
			"radius": mark["radius"],
		})


func _emit_activated(mark: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_pagecraft_mark_activated"):
		_event_bus.emit_pagecraft_mark_activated({
			"material_tag": mark["material_tag"],
			"source_id": mark["source_id"],
			"world_position": mark["position"],
			"radius": mark["radius"],
		})
