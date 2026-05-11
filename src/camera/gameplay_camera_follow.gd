class_name GameplayCameraFollow
extends Node

@export_range(0.01, 1.0, 0.01) var follow_smoothing_seconds := 0.12
@export_range(0.0, 2.0, 0.01) var lookahead_seconds := 0.18
@export var page_half_extents := Vector2(4.5, 2.8)

var _target: Node3D
var _camera_rig: Node3D


## Configures the follow target and the rig this service moves.
func configure(target: Node3D, camera_rig: Node3D) -> void:
	_target = target
	_camera_rig = camera_rig


func _physics_process(delta: float) -> void:
	if _target == null or _camera_rig == null:
		return
	var desired := _desired_position()
	var smoothing := 1.0
	if follow_smoothing_seconds > 0.0:
		smoothing = 1.0 - exp(-delta / follow_smoothing_seconds)
	_camera_rig.global_position = _camera_rig.global_position.lerp(desired, smoothing)


func _desired_position() -> Vector3:
	var target_position := _target.global_position
	if _target is CharacterBody3D:
		target_position += (_target as CharacterBody3D).velocity * lookahead_seconds
	target_position.x = clampf(target_position.x, -page_half_extents.x, page_half_extents.x)
	target_position.z = clampf(target_position.z, -page_half_extents.y, page_half_extents.y)
	target_position.y = 0.0
	return target_position
