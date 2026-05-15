class_name MvpWeaponEffects
extends RefCounted

const DREAMSAP_FEEDBACK_SECONDS := 2.6
const COLOR_BLOOM_FEEDBACK_SECONDS := 0.85


static func fire_dreamsap_glob(parent: Node, enemies_root: Node, damage_model, weapon_data: Resource, mark_radius_meters: float, target: Node3D, damage: float) -> Dictionary:
	if target == null:
		return {"hits": 0, "transients": []}
	var center := Vector3(target.global_position.x, 0.08, target.global_position.z)
	var radius := maxf(0.65, mark_radius_meters)
	var hits := _apply_area_damage(enemies_root, damage_model, weapon_data.id, damage, weapon_data.material_tags, center, radius)
	return {
		"hits": hits,
		"transients": [_create_dreamsap_feedback(parent, center, radius)],
	}


static func fire_color_bloom(parent: Node, enemies_root: Node, damage_model, weapon_data: Resource, mark_radius_meters: float, target: Node3D, damage: float) -> Dictionary:
	if target == null:
		return {"hits": 0, "transients": []}
	var center := Vector3(target.global_position.x, 0.09, target.global_position.z)
	var radius := maxf(0.7, mark_radius_meters * 1.15)
	var hits := _apply_area_damage(enemies_root, damage_model, weapon_data.id, damage, weapon_data.material_tags, center, radius)
	return {
		"hits": hits,
		"transients": [_create_color_bloom_feedback(parent, center, radius)],
	}


static func _apply_area_damage(enemies_root: Node, damage_model, source_id: StringName, damage: float, damage_tags: Array, center: Vector3, radius: float) -> int:
	if enemies_root == null or damage_model == null:
		return 0
	var hits := 0
	for enemy in enemies_root.get_children():
		if not enemy is Node3D:
			continue
		if (enemy as Node3D).global_position.distance_to(center) > radius:
			continue
		var health := enemy.get_node_or_null("HealthComponent")
		if health == null or not health.has_method("is_alive") or not health.is_alive():
			continue
		var result: Dictionary = damage_model.apply_damage(health, source_id, damage, damage_tags)
		if not result.is_empty():
			hits += 1
	return hits


static func _create_dreamsap_feedback(parent: Node, world_position: Vector3, radius: float) -> Dictionary:
	var visual := MeshInstance3D.new()
	visual.name = "DreamsapGlobPuddle"
	visual.top_level = true
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.04
	mesh.radial_segments = 14
	visual.mesh = mesh
	visual.material_override = _material(Color(0.48, 0.24, 0.78, 0.48), Color(0.55, 0.30, 0.95, 1.0), 0.65)
	parent.add_child(visual)
	visual.global_position = world_position
	return {"visual": visual, "remaining": DREAMSAP_FEEDBACK_SECONDS}


static func _create_color_bloom_feedback(parent: Node, world_position: Vector3, radius: float) -> Dictionary:
	var visual := MeshInstance3D.new()
	visual.name = "ColorBloomBurst"
	visual.top_level = true
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.055
	mesh.radial_segments = 18
	visual.mesh = mesh
	visual.material_override = _material(Color(0.95, 0.25, 0.58, 0.5), Color(0.2, 0.9, 0.55, 1.0), 0.9)
	parent.add_child(visual)
	visual.global_position = world_position
	return {"visual": visual, "remaining": COLOR_BLOOM_FEEDBACK_SECONDS}


static func _material(albedo: Color, emission: Color, emission_multiplier: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = albedo
	material.emission_enabled = true
	material.emission = emission
	material.emission_energy_multiplier = emission_multiplier
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return material
