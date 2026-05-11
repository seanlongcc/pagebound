class_name ShellRefs
extends RefCounted

## Typed references to the canonical Pagebound shell mount points.
var run_root: Node3D
var level_root: Node3D
var page_ground: MeshInstance3D
var actors: Node3D
var players: Node3D
var pets: Node3D
var enemies: Node3D
var bosses: Node3D
var projectiles: Node3D
var pagecraft: Node3D
var pickups: Node3D
var vfx: Node3D
var damage_numbers: Node3D
var camera_rig: Node3D
var camera: Camera3D
var lighting: Node3D
var directional_light: DirectionalLight3D
var world_environment: WorldEnvironment
var ui: CanvasLayer
var hud: Control
var modal_layer: Control
var level_up_screen: Control
var pause_menu: Control
var victory_screen: Control
var debug_overlay: Control


## Returns true when every required shell reference is present.
func has_all_required_refs() -> bool:
	return missing_required_field_names().is_empty()


## Returns field names that are still null.
func missing_required_field_names() -> Array[String]:
	var missing: Array[String] = []
	for field in _required_fields():
		if field["value"] == null:
			missing.append(field["name"])
	return missing


func _required_fields() -> Array[Dictionary]:
	return [
		{"name": "run_root", "value": run_root},
		{"name": "level_root", "value": level_root},
		{"name": "page_ground", "value": page_ground},
		{"name": "actors", "value": actors},
		{"name": "players", "value": players},
		{"name": "pets", "value": pets},
		{"name": "enemies", "value": enemies},
		{"name": "bosses", "value": bosses},
		{"name": "projectiles", "value": projectiles},
		{"name": "pagecraft", "value": pagecraft},
		{"name": "pickups", "value": pickups},
		{"name": "vfx", "value": vfx},
		{"name": "damage_numbers", "value": damage_numbers},
		{"name": "camera_rig", "value": camera_rig},
		{"name": "camera", "value": camera},
		{"name": "lighting", "value": lighting},
		{"name": "directional_light", "value": directional_light},
		{"name": "world_environment", "value": world_environment},
		{"name": "ui", "value": ui},
		{"name": "hud", "value": hud},
		{"name": "modal_layer", "value": modal_layer},
		{"name": "level_up_screen", "value": level_up_screen},
		{"name": "pause_menu", "value": pause_menu},
		{"name": "victory_screen", "value": victory_screen},
		{"name": "debug_overlay", "value": debug_overlay},
	]
