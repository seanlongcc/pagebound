class_name PlayerController
extends CharacterBody3D

signal dash_path_sampled(start_position: Vector3, end_position: Vector3)

const InputActionsScript := preload("res://src/input/input_actions.gd")

@export_range(1.0, 20.0, 0.1) var move_speed := 7.0
@export_range(1.0, 40.0, 0.1) var dash_speed := 14.0
@export_range(0.01, 1.0, 0.01) var dash_active_seconds := 0.15
@export_range(0.0, 1.0, 0.01) var dash_recovery_seconds := 0.14
@export_range(0.1, 5.0, 0.01) var dash_cooldown_seconds := 0.9
@export var page_half_extents := Vector2(7.7, 4.7)

var _input_actions = InputActionsScript.new()
var _camera: Camera3D
var _last_move_direction := Vector3.FORWARD
var _dash_direction := Vector3.ZERO
var _dash_start_position := Vector3.ZERO
var _dash_time_remaining := 0.0
var _dash_cooldown_remaining := 0.0
var _dash_recovery_remaining := 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 1
	collision_mask = 0
	_ensure_placeholder_nodes()


func _physics_process(delta: float) -> void:
	_integrate(_input_actions.movement_vector(), _input_actions.dash_just_pressed(), delta, false)


## Assigns the camera used for camera-relative movement.
func set_follow_camera(camera: Camera3D) -> void:
	_camera = camera


## Integrates one deterministic movement tick for smoke tests.
func debug_integrate(move_input: Vector2, dash_pressed: bool, delta: float) -> void:
	_integrate(move_input, dash_pressed, delta, true)


## Returns true while active dash travel is happening.
func is_dashing() -> bool:
	return _dash_time_remaining > 0.0


## Returns expected straight-line dash travel distance for smoke tuning.
func debug_dash_distance() -> float:
	return dash_speed * dash_active_seconds


## Clears dash timers for deterministic smoke checks.
func debug_force_dash_ready() -> void:
	_dash_time_remaining = 0.0
	_dash_cooldown_remaining = 0.0
	_dash_recovery_remaining = 0.0


## Resets spawn position for retry and menu-start flows.
func reset_to_spawn_position(spawn_position: Vector3) -> void:
	global_position = spawn_position


func _integrate(move_input: Vector2, dash_pressed: bool, delta: float, manual_motion: bool) -> void:
	_tick_timers(delta)
	var move_direction := _input_to_world_direction(move_input)
	if move_direction.length_squared() > 0.0:
		_last_move_direction = move_direction

	if dash_pressed and _can_start_dash():
		_start_dash()

	if is_dashing():
		_integrate_dash(delta, manual_motion)
		return

	velocity = move_direction * move_speed
	velocity.y = 0.0
	_apply_motion(delta, manual_motion)


func _tick_timers(delta: float) -> void:
	_dash_cooldown_remaining = maxf(0.0, _dash_cooldown_remaining - delta)
	_dash_recovery_remaining = maxf(0.0, _dash_recovery_remaining - delta)


func _can_start_dash() -> bool:
	return _dash_cooldown_remaining <= 0.0 and _dash_recovery_remaining <= 0.0 and not is_dashing()


func _start_dash() -> void:
	_dash_direction = _last_move_direction.normalized()
	if _dash_direction.length_squared() == 0.0:
		_dash_direction = Vector3.FORWARD
	_dash_start_position = global_position
	_dash_time_remaining = dash_active_seconds
	_dash_cooldown_remaining = dash_cooldown_seconds


func _integrate_dash(delta: float, manual_motion: bool) -> void:
	velocity = _dash_direction * dash_speed
	velocity.y = 0.0
	_apply_motion(delta, manual_motion)
	_dash_time_remaining = maxf(0.0, _dash_time_remaining - delta)
	if _dash_time_remaining <= 0.0:
		_dash_recovery_remaining = dash_recovery_seconds
		dash_path_sampled.emit(_dash_start_position, global_position)


func _apply_motion(delta: float, manual_motion: bool) -> void:
	if manual_motion:
		global_position += velocity * delta
	else:
		move_and_slide()
	_clamp_to_page()


func _input_to_world_direction(move_input: Vector2) -> Vector3:
	if move_input.length_squared() == 0.0:
		return Vector3.ZERO
	var input := move_input.normalized() if move_input.length() > 1.0 else move_input
	var right := Vector3.RIGHT
	var forward := Vector3.FORWARD
	if _camera != null:
		right = _flattened(_camera.global_transform.basis.x)
		forward = _flattened(-_camera.global_transform.basis.z)
	return (right * input.x + forward * -input.y).normalized()


func _clamp_to_page() -> void:
	global_position.x = clampf(global_position.x, -page_half_extents.x, page_half_extents.x)
	global_position.z = clampf(global_position.z, -page_half_extents.y, page_half_extents.y)


func _flattened(value: Vector3) -> Vector3:
	var flattened := Vector3(value.x, 0.0, value.z)
	if flattened.length_squared() == 0.0:
		return Vector3.ZERO
	return flattened.normalized()


func _ensure_placeholder_nodes() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var collision := CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		var shape := CapsuleShape3D.new()
		shape.radius = 0.35
		shape.height = 1.2
		collision.shape = shape
		collision.position.y = 0.6
		add_child(collision)

	if get_node_or_null("PlaceholderMesh") == null:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "PlaceholderMesh"
		var mesh := BoxMesh.new()
		mesh.size = Vector3(0.75, 0.55, 0.75)
		mesh_instance.mesh = mesh
		mesh_instance.position.y = 0.35
		mesh_instance.material_override = _placeholder_material(Color(0.2, 0.45, 0.95, 1.0))
		add_child(mesh_instance)


func _placeholder_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.75
	return material
