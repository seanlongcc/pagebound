class_name GameBootstrap
extends Node

signal shell_ready(shell_refs)

const ShellRefsScript := preload("res://src/shell/shell_refs.gd")
const ShellValidationResultScript := preload("res://src/shell/shell_validation_result.gd")
const MAIN_SCENE := "res://Main.tscn"
const BOOTSTRAP_SCRIPT := "res://src/shell/game_bootstrap.gd"
const APPROVED_SHELL_SCRIPT_PREFIXES := ["res://src/shell/"]
const FORBIDDEN_GAMEPLAY_GROUPS := [
	"gameplay",
	"combat",
	"spawner",
	"progression",
	"pagecraft_rule",
	"save_schema",
	"pool_manager",
]
const REQUIRED_NODE_CHECKS := [
	{"id": "has_run_root", "path": "RunRoot", "type": "Node3D"},
	{"id": "has_level_root", "path": "RunRoot/LevelRoot", "type": "Node3D"},
	{"id": "has_page_ground", "path": "RunRoot/LevelRoot/PageGround", "type": "MeshInstance3D"},
	{"id": "has_environment_props_root", "path": "RunRoot/LevelRoot/EnvironmentProps", "type": "Node3D"},
	{"id": "has_boundaries_root", "path": "RunRoot/LevelRoot/Boundaries", "type": "Node3D"},
	{"id": "has_spawn_zones_root", "path": "RunRoot/LevelRoot/SpawnZones", "type": "Node3D"},
	{"id": "has_quest_locations_root", "path": "RunRoot/LevelRoot/QuestLocations", "type": "Node3D"},
	{"id": "has_actors_root", "path": "RunRoot/Actors", "type": "Node3D"},
	{"id": "has_players_root", "path": "RunRoot/Actors/Players", "type": "Node3D"},
	{"id": "has_pets_root", "path": "RunRoot/Actors/Pets", "type": "Node3D"},
	{"id": "has_enemies_root", "path": "RunRoot/Actors/Enemies", "type": "Node3D"},
	{"id": "has_bosses_root", "path": "RunRoot/Actors/Bosses", "type": "Node3D"},
	{"id": "has_projectiles_root", "path": "RunRoot/Projectiles", "type": "Node3D"},
	{"id": "has_pagecraft_root", "path": "RunRoot/Pagecraft", "type": "Node3D"},
	{"id": "has_pickups_root", "path": "RunRoot/Pickups", "type": "Node3D"},
	{"id": "has_vfx_root", "path": "RunRoot/VFX", "type": "Node3D"},
	{"id": "has_damage_numbers_root", "path": "RunRoot/DamageNumbers", "type": "Node3D"},
	{"id": "has_camera_rig", "path": "RunRoot/CameraRig", "type": "Node3D"},
	{"id": "has_camera", "path": "RunRoot/CameraRig/Camera3D", "type": "Camera3D"},
	{"id": "has_lighting_root", "path": "RunRoot/Lighting", "type": "Node3D"},
	{"id": "has_directional_light", "path": "RunRoot/Lighting/DirectionalLight3D", "type": "DirectionalLight3D"},
	{"id": "has_world_environment", "path": "RunRoot/Lighting/WorldEnvironment", "type": "WorldEnvironment"},
	{"id": "has_ui_root", "path": "UI", "type": "CanvasLayer"},
	{"id": "has_hud_slot", "path": "UI/HUD", "type": "Control"},
	{"id": "has_modal_layer", "path": "UI/ModalLayer", "type": "Control"},
	{"id": "has_level_up_slot", "path": "UI/ModalLayer/LevelUpScreen", "type": "Control"},
	{"id": "has_pause_slot", "path": "UI/ModalLayer/PauseMenu", "type": "Control"},
	{"id": "has_victory_slot", "path": "UI/ModalLayer/VictoryScreen", "type": "Control"},
	{"id": "has_debug_overlay_slot", "path": "UI/DebugOverlay", "type": "Control"},
]
const DUPLICATE_SCOPES := [
	{"parent": "", "name": "GameBootstrap"},
	{"parent": "", "name": "RunRoot"},
	{"parent": "", "name": "UI"},
	{"parent": "RunRoot", "name": "LevelRoot"},
	{"parent": "RunRoot", "name": "Actors"},
	{"parent": "RunRoot", "name": "Projectiles"},
	{"parent": "RunRoot", "name": "Pagecraft"},
	{"parent": "RunRoot", "name": "Pickups"},
	{"parent": "RunRoot", "name": "VFX"},
	{"parent": "RunRoot", "name": "DamageNumbers"},
	{"parent": "RunRoot", "name": "CameraRig"},
	{"parent": "RunRoot", "name": "Lighting"},
	{"parent": "RunRoot/LevelRoot", "name": "PageGround"},
	{"parent": "RunRoot/LevelRoot", "name": "EnvironmentProps"},
	{"parent": "RunRoot/LevelRoot", "name": "Boundaries"},
	{"parent": "RunRoot/LevelRoot", "name": "SpawnZones"},
	{"parent": "RunRoot/LevelRoot", "name": "QuestLocations"},
	{"parent": "RunRoot/Actors", "name": "Players"},
	{"parent": "RunRoot/Actors", "name": "Pets"},
	{"parent": "RunRoot/Actors", "name": "Enemies"},
	{"parent": "RunRoot/Actors", "name": "Bosses"},
	{"parent": "RunRoot/CameraRig", "name": "Camera3D"},
	{"parent": "RunRoot/Lighting", "name": "DirectionalLight3D"},
	{"parent": "RunRoot/Lighting", "name": "WorldEnvironment"},
	{"parent": "UI", "name": "HUD"},
	{"parent": "UI", "name": "ModalLayer"},
	{"parent": "UI", "name": "DebugOverlay"},
	{"parent": "UI/ModalLayer", "name": "LevelUpScreen"},
	{"parent": "UI/ModalLayer", "name": "PauseMenu"},
	{"parent": "UI/ModalLayer", "name": "VictoryScreen"},
]

@export var boot_validation_enabled := true
@export var fatal_on_boot_error_in_editor := true
@export var allow_placeholder_boot := true
@export var show_debug_overlay_on_boot := false
@export_range(500, 10000, 100) var startup_handoff_timeout_ms := 2000

var _shell_ready_emitted := false


func _ready() -> void:
	if not boot_validation_enabled:
		return

	var result = validate_shell(get_parent())
	if not result.shell_ready_allowed:
		_report_boot_failure(result)
		return

	_emit_shell_ready_once(result.shell_refs)


## Validates the Pagebound shell topology and returns typed shell refs on success.
func validate_shell(root: Node):
	var result = ShellValidationResultScript.new()
	var refs = _build_shell_refs(root)
	result.shell_refs = refs

	_add_main_scene_check(result)
	_add_main_root_check(result, root)
	_add_game_bootstrap_check(result, root)

	for check in REQUIRED_NODE_CHECKS:
		_add_required_node_check(result, root, check)

	_add_duplicate_check(result, root)
	_add_placeholder_check(result, refs)
	_add_no_gameplay_logic_check(result, root)
	_add_shell_refs_check(result, refs)

	result.finalize()
	return result


func _add_main_scene_check(result) -> void:
	var configured_scene := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	result.add_check(
		"has_configured_main_scene",
		configured_scene == MAIN_SCENE,
		"BOOT_SHELL_MISSING_MAIN_SCENE",
		"Project main scene must be %s, found %s." % [MAIN_SCENE, configured_scene],
		{"expected_path": MAIN_SCENE, "actual_path": configured_scene}
	)


func _add_main_root_check(result, root: Node) -> void:
	result.add_check(
		"has_main_root",
		root is Node3D,
		"BOOT_SHELL_WRONG_PATH_OR_TYPE",
		"Main root must be Node3D.",
		{"expected_path": "Main", "actual_path": _node_path(root), "expected_type": "Node3D", "actual_type": _node_type(root)}
	)


func _add_game_bootstrap_check(result, root: Node) -> void:
	var bootstrap := _node_at(root, "GameBootstrap")
	var has_expected_script := bootstrap != null and _script_path(bootstrap) == BOOTSTRAP_SCRIPT
	result.add_check(
		"has_game_bootstrap",
		bootstrap is Node and has_expected_script,
		"BOOT_SHELL_WRONG_PATH_OR_TYPE",
		"Main/GameBootstrap must exist as Node with GameBootstrap script.",
		{
			"expected_path": "Main/GameBootstrap",
			"actual_path": _node_path(bootstrap),
			"expected_type": "Node",
			"actual_type": _node_type(bootstrap),
			"expected_script": BOOTSTRAP_SCRIPT,
			"actual_script": _script_path(bootstrap),
		}
	)


func _add_required_node_check(result, root: Node, check: Dictionary) -> void:
	var path := str(check["path"])
	var expected_type := str(check["type"])
	var node := _node_at(root, path)
	result.add_check(
		str(check["id"]),
		node != null and _node_matches_type(node, expected_type),
		"BOOT_SHELL_WRONG_PATH_OR_TYPE",
		"%s must exist as %s." % [_main_path(path), expected_type],
		{
			"expected_path": _main_path(path),
			"actual_path": _node_path(node),
			"expected_type": expected_type,
			"actual_type": _node_type(node),
		}
	)


func _add_duplicate_check(result, root: Node) -> void:
	var duplicate_paths: Array[String] = []
	for scope in DUPLICATE_SCOPES:
		var parent := _node_at(root, str(scope["parent"]))
		if parent == null:
			continue
		var matching_paths := _matching_direct_child_paths(root, parent, str(scope["name"]))
		if matching_paths.size() > 1:
			duplicate_paths.append_array(matching_paths)

	result.add_check(
		"has_no_duplicate_canonical_roots",
		duplicate_paths.is_empty(),
		"BOOT_SHELL_DUPLICATE_ROOT",
		"Duplicate canonical shell roots found.",
		{"duplicate_paths": duplicate_paths}
	)


func _add_placeholder_check(result, refs) -> void:
	var is_visible_to_camera := false
	if refs.page_ground != null and refs.camera != null and refs.page_ground.is_inside_tree():
		is_visible_to_camera = refs.camera.is_position_in_frustum(refs.page_ground.global_position)

	var passed: bool = (
		allow_placeholder_boot
		and refs.page_ground != null
		and refs.page_ground.visible
		and refs.page_ground.mesh != null
		and refs.camera != null
		and refs.camera.current
		and is_visible_to_camera
		and refs.directional_light != null
		and refs.directional_light.visible
		and refs.directional_light.light_energy > 0.0
		and refs.world_environment != null
		and refs.world_environment.environment != null
	)
	result.add_check(
		"has_placeholder_boot_visual",
		passed,
		"BOOT_SHELL_PLACEHOLDER_VISUAL_INVALID",
		"Placeholder boot must show PageGround with active camera, light, and WorldEnvironment.",
		{"page_ground_visible_to_camera": is_visible_to_camera}
	)


func _add_no_gameplay_logic_check(result, root: Node) -> void:
	var contaminations: Array[String] = []
	for node in _canonical_nodes(root):
		var script_path := _script_path(node)
		if script_path != "" and not _path_has_allowed_prefix(script_path):
			contaminations.append("%s has script %s" % [_node_path(node), script_path])
		for group in node.get_groups():
			if FORBIDDEN_GAMEPLAY_GROUPS.has(str(group)):
				contaminations.append("%s has forbidden group %s" % [_node_path(node), str(group)])

	result.add_check(
		"has_no_shell_gameplay_logic",
		contaminations.is_empty(),
		"BOOT_SHELL_GAMEPLAY_CONTAMINATION",
		"Shell-owned nodes must not contain gameplay scripts or groups.",
		{"contaminations": contaminations}
	)


func _add_shell_refs_check(result, refs) -> void:
	var missing_fields: Array[String] = refs.missing_required_field_names()
	result.add_check(
		"has_shell_refs_payload",
		refs.has_all_required_refs(),
		"BOOT_SHELL_INVALID_REFS",
		"ShellRefs must contain every required typed field.",
		{"missing_fields": missing_fields}
	)


func _build_shell_refs(root: Node):
	var refs = ShellRefsScript.new()
	refs.run_root = _node_at(root, "RunRoot") as Node3D
	refs.level_root = _node_at(root, "RunRoot/LevelRoot") as Node3D
	refs.page_ground = _node_at(root, "RunRoot/LevelRoot/PageGround") as MeshInstance3D
	refs.actors = _node_at(root, "RunRoot/Actors") as Node3D
	refs.players = _node_at(root, "RunRoot/Actors/Players") as Node3D
	refs.pets = _node_at(root, "RunRoot/Actors/Pets") as Node3D
	refs.enemies = _node_at(root, "RunRoot/Actors/Enemies") as Node3D
	refs.bosses = _node_at(root, "RunRoot/Actors/Bosses") as Node3D
	refs.projectiles = _node_at(root, "RunRoot/Projectiles") as Node3D
	refs.pagecraft = _node_at(root, "RunRoot/Pagecraft") as Node3D
	refs.pickups = _node_at(root, "RunRoot/Pickups") as Node3D
	refs.vfx = _node_at(root, "RunRoot/VFX") as Node3D
	refs.damage_numbers = _node_at(root, "RunRoot/DamageNumbers") as Node3D
	refs.camera_rig = _node_at(root, "RunRoot/CameraRig") as Node3D
	refs.camera = _node_at(root, "RunRoot/CameraRig/Camera3D") as Camera3D
	refs.lighting = _node_at(root, "RunRoot/Lighting") as Node3D
	refs.directional_light = _node_at(root, "RunRoot/Lighting/DirectionalLight3D") as DirectionalLight3D
	refs.world_environment = _node_at(root, "RunRoot/Lighting/WorldEnvironment") as WorldEnvironment
	refs.ui = _node_at(root, "UI") as CanvasLayer
	refs.hud = _node_at(root, "UI/HUD") as Control
	refs.modal_layer = _node_at(root, "UI/ModalLayer") as Control
	refs.level_up_screen = _node_at(root, "UI/ModalLayer/LevelUpScreen") as Control
	refs.pause_menu = _node_at(root, "UI/ModalLayer/PauseMenu") as Control
	refs.victory_screen = _node_at(root, "UI/ModalLayer/VictoryScreen") as Control
	refs.debug_overlay = _node_at(root, "UI/DebugOverlay") as Control
	return refs


func _canonical_nodes(root: Node) -> Array[Node]:
	var nodes: Array[Node] = []
	if root != null:
		nodes.append(root)
		var bootstrap := _node_at(root, "GameBootstrap")
		if bootstrap != null:
			nodes.append(bootstrap)
	for check in REQUIRED_NODE_CHECKS:
		var node := _node_at(root, str(check["path"]))
		if node != null:
			nodes.append(node)
	return nodes


func _node_at(root: Node, relative_path: String) -> Node:
	if root == null:
		return null
	if relative_path == "":
		return root
	return root.get_node_or_null(relative_path)


func _node_matches_type(node: Node, expected_type: String) -> bool:
	match expected_type:
		"Node":
			return node is Node
		"Node3D":
			return node is Node3D
		"MeshInstance3D":
			return node is MeshInstance3D
		"Camera3D":
			return node is Camera3D
		"DirectionalLight3D":
			return node is DirectionalLight3D
		"WorldEnvironment":
			return node is WorldEnvironment
		"CanvasLayer":
			return node is CanvasLayer
		"Control":
			return node is Control
		_:
			return false


func _matching_direct_child_paths(root: Node, parent: Node, child_name: String) -> Array[String]:
	var paths: Array[String] = []
	for child in parent.get_children():
		if child.name == child_name:
			paths.append(_relative_main_path(root, child))
	return paths


func _relative_main_path(root: Node, node: Node) -> String:
	if root == null or node == null:
		return ""
	if node == root:
		return "Main"
	return "Main/%s" % str(root.get_path_to(node))


func _main_path(relative_path: String) -> String:
	if relative_path == "":
		return "Main"
	return "Main/%s" % relative_path


func _node_path(node: Node) -> String:
	if node == null:
		return ""
	return str(node.get_path())


func _node_type(node: Node) -> String:
	if node == null:
		return "null"
	return node.get_class()


func _script_path(node: Node) -> String:
	if node == null or node.get_script() == null:
		return ""
	return node.get_script().resource_path


func _path_has_allowed_prefix(path: String) -> bool:
	for prefix in APPROVED_SHELL_SCRIPT_PREFIXES:
		if path.begins_with(prefix):
			return true
	return false


func _emit_shell_ready_once(shell_refs) -> void:
	if _shell_ready_emitted:
		push_error("BOOT_SHELL_DUPLICATE_HANDOFF: shell_ready already emitted.")
		return
	_shell_ready_emitted = true
	shell_ready.emit(shell_refs)


func _report_boot_failure(result) -> void:
	var messages: Array[String] = result.failed_messages()
	push_error("BOOT_SHELL_VALIDATION_FAILED: " + "; ".join(messages))
