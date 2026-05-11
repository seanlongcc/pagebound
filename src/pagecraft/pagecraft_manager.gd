class_name PagecraftManager
extends Node

@export_range(0.05, 2.0, 0.05) var dash_activation_padding := 0.45

var _event_bus: Node
var _pagecraft_root: Node3D
var _marks: Array[Dictionary] = []
var _activation_count := 0


## Configures the Pagecraft manager root and event output.
func configure(event_bus: Node, pagecraft_root: Node3D) -> void:
	_event_bus = event_bus
	_pagecraft_root = pagecraft_root


## Deposits a visible primitive mark on the page.
func deposit_mark(world_position: Vector3, material_tag: StringName, radius: float, source_id: StringName) -> void:
	var mark_visual := _create_mark_visual(world_position, radius, false)
	var mark := {
		"position": Vector3(world_position.x, 0.04, world_position.z),
		"radius": radius,
		"material_tag": material_tag,
		"source_id": source_id,
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
			_activate_mark(index)


## Returns active mark count for smoke/debug checks.
func debug_mark_count() -> int:
	return _marks.size()


## Returns activation count for smoke/debug checks.
func debug_activation_count() -> int:
	return _activation_count


## Returns the first mark position for smoke/debug checks.
func debug_first_mark_position() -> Vector3:
	if _marks.is_empty():
		return Vector3.ZERO
	return _marks[0]["position"]


func _activate_mark(index: int) -> void:
	var mark := _marks[index]
	mark["activated"] = true
	_marks[index] = mark
	_activation_count += 1
	var visual = mark.get("visual", null)
	if visual is MeshInstance3D:
		(visual as MeshInstance3D).material_override = _mark_material(true)
		(visual as MeshInstance3D).scale *= 1.35
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
