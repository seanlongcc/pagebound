class_name PrimitiveWeaponEffects
extends RefCounted

const PAPER_PLANE_FEEDBACK_SECONDS := 0.24
const MARGIN_SPARK_FEEDBACK_SECONDS := 0.42


static func fire_paper_plane_dart(parent: Node, owner: Node3D, damage_model, weapon_data: Resource, level_data: Resource, target: Node3D, damage: float) -> Dictionary:
	var health := target.get_node_or_null("HealthComponent")
	if health == null:
		return {"hits": 0, "transients": []}
	damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
	return {
		"hits": 1,
		"transients": [_create_paper_plane_feedback(parent, owner.global_position, target.global_position)],
	}


static func fire_margin_spark_ring(parent: Node, enemies_root: Node, damage_model, weapon_data: Resource, level_data: Resource, target: Node3D, damage: float) -> Dictionary:
	if enemies_root == null:
		return {"hits": 0, "transients": []}
	var center := target.global_position
	var radius := maxf(1.1, float(level_data.mark_radius_meters) * 1.9)
	var hits := 0
	for enemy in enemies_root.get_children():
		if not enemy is Node3D or not _is_living_enemy(enemy as Node3D):
			continue
		if (enemy as Node3D).global_position.distance_to(center) > radius:
			continue
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null:
			continue
		var result: Dictionary = damage_model.apply_damage(health, weapon_data.id, damage, weapon_data.material_tags)
		if not result.is_empty():
			hits += 1
	return {
		"hits": hits,
		"transients": [_create_margin_spark_feedback(parent, center, radius)],
	}


static func _create_paper_plane_feedback(parent: Node, start_position: Vector3, end_position: Vector3) -> Dictionary:
	var start_flat := Vector3(start_position.x, 0.66, start_position.z)
	var end_flat := Vector3(end_position.x, 0.66, end_position.z)
	var direction := end_flat - start_flat
	var length := direction.length()
	if length <= 0.01:
		return {}
	var visual := MeshInstance3D.new()
	visual.name = "PaperPlaneDartTrail"
	visual.top_level = true
	var mesh := BoxMesh.new()
	mesh.size = Vector3(length, 0.035, 0.075)
	visual.mesh = mesh
	visual.material_override = _primitive_material(Color(0.38, 0.72, 1.0, 0.78), 0.65)
	parent.add_child(visual)
	visual.global_position = start_flat + direction * 0.5
	var normalized := direction.normalized()
	visual.rotation.y = atan2(-normalized.z, normalized.x)
	return {"visual": visual, "remaining": PAPER_PLANE_FEEDBACK_SECONDS}


static func _create_margin_spark_feedback(parent: Node, world_position: Vector3, radius: float) -> Dictionary:
	var visual := MeshInstance3D.new()
	visual.name = "MarginSparkRing"
	visual.top_level = true
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.04
	mesh.radial_segments = 18
	visual.mesh = mesh
	visual.material_override = _primitive_material(Color(0.32, 0.95, 0.62, 0.38), 0.95)
	parent.add_child(visual)
	visual.global_position = Vector3(world_position.x, 0.11, world_position.z)
	return {"visual": visual, "remaining": MARGIN_SPARK_FEEDBACK_SECONDS}


static func _primitive_material(color: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_multiplier
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material


static func _is_living_enemy(candidate: Node3D) -> bool:
	if candidate == null:
		return false
	var health := candidate.get_node_or_null("HealthComponent")
	return health != null and health.has_method("is_alive") and health.is_alive()
