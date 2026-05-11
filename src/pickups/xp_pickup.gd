class_name XpPickup
extends Node3D

signal collected(pickup: Node, amount: int)

@export_range(1, 100000, 1) var amount := 1
@export_range(0.1, 5.0, 0.05) var collect_radius := 0.75

var _collector: Node3D
var _collected := false


func _ready() -> void:
	add_to_group("xp_pickup")
	_ensure_placeholder_nodes()
	set_physics_process(visible)


func _physics_process(_delta: float) -> void:
	if _collector == null or _collected:
		return
	if _collector.global_position.distance_to(global_position) <= collect_radius:
		_collect()


## Configures one visible Color Mote pickup.
func configure(new_amount: int, collector: Node3D) -> void:
	amount = maxi(1, new_amount)
	_collector = collector
	_collected = false
	visible = true
	set_physics_process(true)


## Returns true until collected, for smoke/debug checks.
func is_collectible() -> bool:
	return visible and not _collected


func _collect() -> void:
	_collected = true
	visible = false
	set_physics_process(false)
	collected.emit(self, amount)


func _ensure_placeholder_nodes() -> void:
	if get_node_or_null("PlaceholderMesh") != null:
		return
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "PlaceholderMesh"
	var mesh := SphereMesh.new()
	mesh.radius = 0.18
	mesh.height = 0.32
	mesh_instance.mesh = mesh
	mesh_instance.position.y = 0.0
	mesh_instance.material_override = _placeholder_material()
	add_child(mesh_instance)


func _placeholder_material() -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.22, 0.9, 1.0, 1.0)
	material.emission_enabled = true
	material.emission = Color(0.05, 0.45, 0.75, 1.0)
	material.emission_energy_multiplier = 0.7
	return material
