class_name PageEventController
extends Node

signal event_started(event: Dictionary)
signal event_completed(event: Dictionary)
signal event_failed(event: Dictionary)

const EVENT_FILL_COLOR_WELL := &"fill_color_well"
const EVENT_TITLE := "Fill the Color Well"
const EVENT_DESCRIPTOR := "Defeat enemies inside the Color Well."
const EVENT_DURATION_SECONDS := 60.0
const REQUIRED_PROGRESS := 15
const EVENT_RADIUS := 5.25
const CURRENT_VISION_HALF_EXTENTS := Vector2(8.5, 5.0)

@export_range(1.0, 1200.0, 1.0) var first_event_time_seconds := 60.0

var _player: Node3D
var _page_half_extents := Vector2(11.0, 7.0)
var _active := false
var _completed := false
var _failed := false
var _elapsed_active := 0.0
var _progress := 0
var _world_position := Vector3.ZERO
var _spawn_outside_current_vision := false
var _edge_marker_visible := false
var _spawn_reachable := false
var _spawn_blocked := false
var _spawn_clipping := false
var _spawn_boss_only := false
var _anchor_visual: MeshInstance3D
var _fill_visual: MeshInstance3D
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()


func configure(player: Node3D, page_half_extents: Vector2) -> void:
	_player = player
	_page_half_extents = page_half_extents


func reset() -> void:
	_active = false
	_completed = false
	_failed = false
	_elapsed_active = 0.0
	_progress = 0
	_world_position = Vector3.ZERO
	_spawn_outside_current_vision = false
	_edge_marker_visible = false
	_spawn_reachable = false
	_spawn_blocked = false
	_spawn_clipping = false
	_spawn_boss_only = false
	_cleanup_anchor_visual()


func update(run_time_seconds: float, delta: float) -> void:
	if not _active and not _completed and not _failed and run_time_seconds >= first_event_time_seconds:
		_start_event()
	if not _active:
		return
	advance_time(delta)


func advance_time(delta: float) -> void:
	if not _active:
		return
	_elapsed_active += maxf(0.0, delta)
	if _progress >= REQUIRED_PROGRESS:
		_complete()
	elif _elapsed_active >= EVENT_DURATION_SECONDS:
		_fail()


func add_kill_progress(death_position: Vector3, amount: int = 1) -> void:
	if not _active:
		return
	if death_position.distance_to(_world_position) > EVENT_RADIUS:
		return
	_progress = mini(REQUIRED_PROGRESS, _progress + maxi(1, amount))
	_update_anchor_progress()
	if _progress >= REQUIRED_PROGRESS:
		_complete()


func force_start() -> void:
	if not _active and not _completed and not _failed:
		_start_event()


func force_complete() -> void:
	if _active:
		_progress = REQUIRED_PROGRESS
		_complete()


func active_event_id() -> StringName:
	if _active:
		return EVENT_FILL_COLOR_WELL
	return &""


func is_active() -> bool:
	return _active


func is_completed() -> bool:
	return _completed


func is_expired() -> bool:
	return _failed


func is_failed() -> bool:
	return _failed


func progress_ratio() -> float:
	return clampf(float(_progress) / float(REQUIRED_PROGRESS), 0.0, 1.0)


func debug_state() -> Dictionary:
	return {
		"id": active_event_id(),
		"active": _active,
		"completed": _completed,
		"failed": _failed,
		"progress": _progress,
		"required_progress": REQUIRED_PROGRESS,
		"progress_ratio": progress_ratio(),
		"progress_percent": floori(progress_ratio() * 100.0),
		"duration_seconds": EVENT_DURATION_SECONDS,
		"time_remaining_seconds": maxf(0.0, EVENT_DURATION_SECONDS - _elapsed_active),
		"world_position": _world_position,
		"radius": EVENT_RADIUS,
		"outside_current_vision": _spawn_outside_current_vision,
		"edge_marker_visible": _edge_marker_visible,
		"spawn_reachable": _spawn_reachable,
		"spawn_blocked": _spawn_blocked,
		"spawn_clipping": _spawn_clipping,
		"spawn_boss_only": _spawn_boss_only,
	}


func debug_first_event_time_seconds() -> float:
	return first_event_time_seconds


func hud_line() -> String:
	if active_event_id() == &"":
		return "Event: none"
	var state := "Active"
	if _completed:
		state = "Complete"
	elif _failed:
		state = "Failed"
	return "Event: Fill the Color Well (%s) %d%% %d/%d %02ds" % [
		state,
		floori(progress_ratio() * 100.0),
		_progress,
		REQUIRED_PROGRESS,
		ceili(maxf(0.0, EVENT_DURATION_SECONDS - _elapsed_active)),
	]


func _start_event() -> void:
	_active = true
	_completed = false
	_failed = false
	_elapsed_active = 0.0
	_progress = 0
	_world_position = _random_offscreen_position()
	_spawn_outside_current_vision = _is_outside_current_vision(_world_position)
	_spawn_reachable = true
	_spawn_blocked = false
	_spawn_clipping = false
	_spawn_boss_only = false
	_edge_marker_visible = _spawn_outside_current_vision
	_ensure_anchor_visual()
	event_started.emit({
		"id": EVENT_FILL_COLOR_WELL,
		"title": EVENT_TITLE,
		"descriptor": EVENT_DESCRIPTOR,
		"world_position": _world_position,
	})


func _complete() -> void:
	_completed = true
	_active = false
	_edge_marker_visible = false
	var event := debug_state()
	event["id"] = EVENT_FILL_COLOR_WELL
	_cleanup_anchor_visual()
	event_completed.emit(event)


func _fail() -> void:
	_failed = true
	_active = false
	_edge_marker_visible = false
	var event := debug_state()
	event["id"] = EVENT_FILL_COLOR_WELL
	_cleanup_anchor_visual()
	event_failed.emit(event)


func _random_offscreen_position() -> Vector3:
	var candidates: Array[Vector3] = []
	for _index in 48:
		var candidate := Vector3(
			_rng.randf_range(-_page_half_extents.x + EVENT_RADIUS, _page_half_extents.x - EVENT_RADIUS),
			0.04,
			_rng.randf_range(-_page_half_extents.y + EVENT_RADIUS, _page_half_extents.y - EVENT_RADIUS)
		)
		if _valid_spawn_position(candidate):
			candidates.append(candidate)
	if candidates.is_empty():
		return Vector3(_page_half_extents.x - EVENT_RADIUS, 0.04, _page_half_extents.y - EVENT_RADIUS)
	return candidates[_rng.randi_range(0, candidates.size() - 1)]


func _valid_spawn_position(candidate: Vector3) -> bool:
	if not _is_outside_current_vision(candidate):
		return false
	var inside_x := absf(candidate.x) <= _page_half_extents.x - EVENT_RADIUS
	var inside_z := absf(candidate.z) <= _page_half_extents.y - EVENT_RADIUS
	return inside_x and inside_z


func _is_outside_current_vision(candidate: Vector3) -> bool:
	var center := Vector3.ZERO
	if _player != null:
		center = _player.global_position
	var delta := Vector2(absf(candidate.x - center.x), absf(candidate.z - center.z))
	return delta.x > CURRENT_VISION_HALF_EXTENTS.x + EVENT_RADIUS or delta.y > CURRENT_VISION_HALF_EXTENTS.y + EVENT_RADIUS


func _ensure_anchor_visual() -> void:
	if _anchor_visual == null:
		_anchor_visual = MeshInstance3D.new()
		_anchor_visual.name = "ColorWellAnchor"
		var mesh := CylinderMesh.new()
		mesh.top_radius = EVENT_RADIUS
		mesh.bottom_radius = EVENT_RADIUS
		mesh.height = 0.035
		mesh.radial_segments = 48
		_anchor_visual.mesh = mesh
		_anchor_visual.material_override = _anchor_material()
		add_child(_anchor_visual)
	if _fill_visual == null:
		_fill_visual = MeshInstance3D.new()
		_fill_visual.name = "ColorWellFill"
		var fill_mesh := CylinderMesh.new()
		fill_mesh.top_radius = EVENT_RADIUS
		fill_mesh.bottom_radius = EVENT_RADIUS
		fill_mesh.height = 0.04
		fill_mesh.radial_segments = 48
		_fill_visual.mesh = fill_mesh
		_fill_visual.material_override = _fill_material()
		add_child(_fill_visual)
	_anchor_visual.global_position = _world_position
	_anchor_visual.visible = true
	_fill_visual.global_position = _world_position + Vector3(0.0, 0.015, 0.0)
	_fill_visual.visible = true
	_update_anchor_progress()


func _update_anchor_progress() -> void:
	if _fill_visual == null:
		return
	var ratio := maxf(0.05, progress_ratio())
	_fill_visual.scale = Vector3(ratio, 1.0, ratio)


func _cleanup_anchor_visual() -> void:
	if _anchor_visual != null:
		_anchor_visual.queue_free()
		_anchor_visual = null
	if _fill_visual != null:
		_fill_visual.queue_free()
		_fill_visual = null


func _anchor_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.22, 0.58, 0.24)
	material.emission_enabled = true
	material.emission = Color(0.95, 0.22, 0.58, 1.0)
	material.emission_energy_multiplier = 0.5
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


func _fill_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.95, 0.74, 0.12, 0.36)
	material.emission_enabled = true
	material.emission = Color(0.95, 0.62, 0.08, 1.0)
	material.emission_energy_multiplier = 0.45
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
