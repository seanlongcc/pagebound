extends SceneTree

const MAIN_SCENE := "res://Main.tscn"
const REQUIRED_CHECK_IDS := [
	"has_configured_main_scene",
	"has_main_root",
	"has_game_bootstrap",
	"has_run_root",
	"has_level_root",
	"has_page_ground",
	"has_environment_props_root",
	"has_boundaries_root",
	"has_spawn_zones_root",
	"has_quest_locations_root",
	"has_actors_root",
	"has_players_root",
	"has_pets_root",
	"has_enemies_root",
	"has_bosses_root",
	"has_projectiles_root",
	"has_pagecraft_root",
	"has_pickups_root",
	"has_vfx_root",
	"has_damage_numbers_root",
	"has_camera_rig",
	"has_camera",
	"has_lighting_root",
	"has_directional_light",
	"has_world_environment",
	"has_ui_root",
	"has_hud_slot",
	"has_modal_layer",
	"has_level_up_slot",
	"has_pause_slot",
	"has_victory_slot",
	"has_debug_overlay_slot",
	"has_no_duplicate_canonical_roots",
	"has_placeholder_boot_visual",
	"has_no_shell_gameplay_logic",
	"has_shell_refs_payload",
]


func _initialize() -> void:
	var failures: Array[String] = []

	_assert_equal(
		ProjectSettings.get_setting("application/run/main_scene", ""),
		MAIN_SCENE,
		"application/run/main_scene must point to Main.tscn",
		failures
	)

	var packed_scene := load(MAIN_SCENE) as PackedScene
	_assert_true(packed_scene != null, "Main.tscn must load", failures)
	if packed_scene == null:
		_finish(failures)
		return

	var root := packed_scene.instantiate()
	_assert_true(root is Node3D, "Main.tscn root must be Node3D", failures)
	if root == null:
		_finish(failures)
		return

	get_root().add_child(root)
	await process_frame

	var bootstrap := root.get_node_or_null("GameBootstrap")
	_assert_true(bootstrap != null, "GameBootstrap node must exist", failures)
	_assert_true(bootstrap != null and bootstrap.has_method("validate_shell"), "GameBootstrap must expose validate_shell", failures)

	if bootstrap != null and bootstrap.has_method("validate_shell"):
		var result = bootstrap.validate_shell(root)
		_assert_equal(result.required_checks, REQUIRED_CHECK_IDS.size(), "all required check IDs must be reported", failures)
		_assert_equal(result.failed_checks, 0, "shell validation must have no failures", failures)
		_assert_equal(result.shell_ready_allowed, true, "shell_ready_allowed must be true", failures)
		for check_id in REQUIRED_CHECK_IDS:
			_assert_true(result.has_check_id(check_id), "missing check result: %s" % check_id, failures)
			_assert_true(result.check_passed(check_id), "check failed: %s" % check_id, failures)

		var shell_refs = result.shell_refs
		_assert_true(shell_refs != null, "ShellRefs payload must exist", failures)
		if shell_refs != null:
			_assert_equal(shell_refs.page_ground, root.get_node("RunRoot/LevelRoot/PageGround"), "page_ground ref must point to PageGround", failures)
			_assert_equal(shell_refs.camera, root.get_node("RunRoot/CameraRig/Camera3D"), "camera ref must point to Camera3D", failures)
			_assert_equal(shell_refs.ui, root.get_node("UI"), "ui ref must point to UI", failures)

	root.queue_free()
	await process_frame
	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_equal(actual, expected, message: String, failures: Array[String]) -> void:
	if actual != expected:
		failures.append("%s (expected: %s, actual: %s)" % [message, str(expected), str(actual)])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("shell smoke check passed")
		quit(0)
		return

	push_error("shell smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
