class_name FirstPlayableRuntime
extends Node

const InputActionsScript := preload("res://src/input/input_actions.gd")
const PlayerControllerScript := preload("res://src/player/player_controller.gd")

@export var enable_first_playable_loop := true

var _input_actions = InputActionsScript.new()


func _ready() -> void:
	if not enable_first_playable_loop:
		return
	_input_actions.ensure_default_actions()
	_spawn_player()


## Returns the current player instance if one exists.
func player() -> CharacterBody3D:
	return _players_root().get_node_or_null("Player") as CharacterBody3D


func _spawn_player() -> void:
	if player() != null:
		return
	var player_body := CharacterBody3D.new()
	player_body.name = "Player"
	player_body.set_script(PlayerControllerScript)
	_players_root().add_child(player_body)
	player_body.global_position = Vector3.ZERO
	if player_body.has_method("set_follow_camera"):
		player_body.set_follow_camera(_camera())


func _run_root() -> Node3D:
	return get_parent() as Node3D


func _players_root() -> Node3D:
	return _run_root().get_node("Actors/Players") as Node3D


func _camera() -> Camera3D:
	return _run_root().get_node("CameraRig/Camera3D") as Camera3D
