class_name ChaserEnemy
extends CharacterBody3D

@export_range(0.0, 20.0, 0.1) var move_speed := 2.6
@export_range(0.0, 10000.0, 0.1) var contact_damage := 5.0
@export_range(0, 100000, 1) var reward_xp := 1

var _target: Node3D
var _health: Node
var _enemy_id: StringName
var _behavior_id: StringName


func _ready() -> void:
	add_to_group("enemy")
	collision_layer = 2
	collision_mask = 0
	_ensure_placeholder_nodes()


func _physics_process(_delta: float) -> void:
	if _target == null or _is_dead():
		velocity = Vector3.ZERO
		return
	var direction := _target.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() == 0.0:
		velocity = Vector3.ZERO
	else:
		velocity = direction.normalized() * move_speed
	move_and_slide()


## Configures this enemy's prototype data and chase target.
func configure(enemy_data: Resource, target: Node3D) -> void:
	_target = target
	if enemy_data != null:
		_enemy_id = enemy_data.id
		_behavior_id = enemy_data.behavior_id
		move_speed = enemy_data.move_speed
		contact_damage = enemy_data.contact_damage
		reward_xp = enemy_data.reward_xp
		_apply_placeholder_profile()


## Assigns the health component used for alive/dead checks.
func set_health_component(health: Node) -> void:
	_health = health


## Returns current distance to target for smoke/debug checks.
func debug_distance_to_target() -> float:
	if _target == null:
		return 999.0
	return global_position.distance_to(_target.global_position)


## Returns configured enemy family ID for smoke/debug checks.
func debug_enemy_id() -> StringName:
	return _enemy_id


## Returns tuned movement speed for smoke/debug checks.
func debug_move_speed() -> float:
	return move_speed


## Returns true while this enemy can be targeted by weapons.
func debug_is_targetable() -> bool:
	return visible and not _is_dead()


func _is_dead() -> bool:
	return _health != null and _health.has_method("is_alive") and not _health.is_alive()


func _ensure_placeholder_nodes() -> void:
	if get_node_or_null("CollisionShape3D") == null:
		var collision := CollisionShape3D.new()
		collision.name = "CollisionShape3D"
		var shape := CapsuleShape3D.new()
		shape.radius = 0.32
		shape.height = 1.0
		collision.shape = shape
		collision.position.y = 0.5
		add_child(collision)

	if get_node_or_null("PlaceholderMesh") == null:
		var mesh_instance := MeshInstance3D.new()
		mesh_instance.name = "PlaceholderMesh"
		var mesh := SphereMesh.new()
		mesh.radius = 0.42
		mesh.height = 0.75
		mesh_instance.mesh = mesh
		mesh_instance.position.y = 0.38
		mesh_instance.material_override = _placeholder_material(Color(0.08, 0.08, 0.1, 1.0))
		add_child(mesh_instance)


func _placeholder_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.8
	return material


func _apply_placeholder_profile() -> void:
	var mesh_instance := get_node_or_null("PlaceholderMesh") as MeshInstance3D
	if mesh_instance == null:
		return
	if _behavior_id == &"boss_chaser":
		mesh_instance.scale = Vector3(2.2, 2.0, 2.2)
		mesh_instance.material_override = _placeholder_material(Color(0.18, 0.05, 0.24, 1.0))
	elif _behavior_id == &"swarmer":
		mesh_instance.scale = Vector3(0.72, 0.72, 0.72)
		mesh_instance.material_override = _placeholder_material(Color(0.46, 0.09, 0.16, 1.0))
	else:
		mesh_instance.scale = Vector3(1.15, 1.05, 1.15)
		mesh_instance.material_override = _placeholder_material(Color(0.06, 0.06, 0.08, 1.0))
