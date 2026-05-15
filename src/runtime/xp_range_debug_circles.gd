class_name XpRangeDebugCircles
extends RefCounted

const PLAYER_XP_PICKUP_RADIUS := 3.0
const SEGMENTS := 96

var _root: Node3D
var _player: Node3D
var _dog: Node
var _enabled := false
var _circles: Dictionary = {}


func configure(root: Node3D, player: Node3D, dog: Node) -> void:
	_root = root
	_player = player
	_dog = dog
	_sync()


func set_visible_enabled(enabled: bool) -> void:
	_enabled = enabled
	_sync()


func circle_count() -> int:
	_sync()
	return _circles.size()


func clear() -> void:
	for visual in _circles.values():
		if visual is Node:
			(visual as Node).queue_free()
	_circles.clear()


func update() -> void:
	if not _enabled:
		return
	_sync()
	_position_circle(&"player", _player)
	_position_circle(&"dog", _dog as Node3D)


func _sync() -> void:
	if not _enabled or _root == null:
		clear()
		return
	_ensure_circle(&"player", "PlayerXPRangeCircle", PLAYER_XP_PICKUP_RADIUS, Color(0.24, 0.78, 1.0, 0.92))
	_ensure_circle(&"dog", "DogXPFetchRangeCircle", _dog_fetch_range(), Color(1.0, 0.72, 0.18, 0.92))
	_position_circle(&"player", _player)
	_position_circle(&"dog", _dog as Node3D)


func _ensure_circle(key: StringName, node_name: String, radius: float, color: Color) -> void:
	var visual = _circles.get(key, null)
	if not visual is MeshInstance3D or not is_instance_valid(visual):
		visual = MeshInstance3D.new()
		visual.name = node_name
		visual.top_level = true
		visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_root.add_child(visual)
		_circles[key] = visual
	if not is_equal_approx(float((visual as Node).get_meta("radius", -1.0)), radius):
		(visual as MeshInstance3D).mesh = _circle_mesh(radius)
		(visual as Node).set_meta("radius", radius)
	(visual as MeshInstance3D).material_override = _circle_material(color)
	(visual as MeshInstance3D).visible = true


func _position_circle(key: StringName, anchor: Node3D) -> void:
	var visual = _circles.get(key, null)
	if not visual is MeshInstance3D:
		return
	if anchor == null:
		(visual as MeshInstance3D).visible = false
		return
	var position := anchor.global_position
	(visual as MeshInstance3D).global_position = Vector3(position.x, 0.07, position.z)
	(visual as MeshInstance3D).visible = true


func _dog_fetch_range() -> float:
	if _dog != null and _dog.has_method("fetch_range"):
		return float(_dog.fetch_range())
	return PLAYER_XP_PICKUP_RADIUS * 2.0


func _circle_mesh(radius: float) -> ImmediateMesh:
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for index in SEGMENTS + 1:
		var angle := TAU * float(index) / float(SEGMENTS)
		mesh.surface_add_vertex(Vector3(cos(angle) * radius, 0.0, sin(angle) * radius))
	mesh.surface_end()
	return mesh


func _circle_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = 0.45
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return material
