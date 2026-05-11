class_name FirstPlayableRuntime
extends Node

const InputActionsScript := preload("res://src/input/input_actions.gd")
const DamageModelScript := preload("res://src/combat/damage_model.gd")
const DamageNumberManagerScript := preload("res://src/feedback/damage_number_manager.gd")
const GameplayCameraFollowScript := preload("res://src/camera/gameplay_camera_follow.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const PlayerControllerScript := preload("res://src/player/player_controller.gd")
const AutoWeaponManagerScript := preload("res://src/weapons/auto_weapon_manager.gd")
const ChaserEnemyScript := preload("res://src/enemies/chaser_enemy.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")

@export var enable_first_playable_loop := true

var _input_actions = InputActionsScript.new()
var _content_factory = PrototypeContentFactoryScript.new()
var _damage_model = DamageModelScript.new()
var _event_bus: Node
var _xp_total := 0


func _ready() -> void:
	if not enable_first_playable_loop:
		return
	call_deferred("_start_first_playable_loop")


func _start_first_playable_loop() -> void:
	_input_actions.ensure_default_actions()
	_ensure_runtime_services()
	_ensure_damage_number_manager()
	_spawn_player()
	_spawn_enemy()
	_ensure_weapon_manager()


## Returns the current player instance if one exists.
func player() -> CharacterBody3D:
	return _players_root().get_node_or_null("Player") as CharacterBody3D


## Returns the scene-owned runtime event bus.
func event_bus() -> Node:
	return _event_bus


## Returns the injected damage model service.
func damage_model():
	return _damage_model


## Returns first-playable XP total for smoke/debug checks.
func debug_xp_total() -> int:
	return _xp_total


func _ensure_runtime_services() -> void:
	_event_bus = _run_root().get_node_or_null("RuntimeEventBus")
	if _event_bus == null:
		_event_bus = RuntimeEventBusScript.new()
		_event_bus.name = "RuntimeEventBus"
		_run_root().add_child(_event_bus)
	_damage_model.configure(_event_bus)
	if _event_bus.has_signal("entity_died") and not _event_bus.entity_died.is_connected(_on_entity_died):
		_event_bus.entity_died.connect(_on_entity_died)


func _ensure_damage_number_manager() -> void:
	var manager := _damage_numbers_root().get_node_or_null("DamageNumberManager")
	if manager == null:
		manager = DamageNumberManagerScript.new()
		manager.name = "DamageNumberManager"
		_damage_numbers_root().add_child(manager)
	if manager.has_method("configure"):
		manager.configure(_event_bus, _damage_numbers_root())


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
	_ensure_health(player_body, &"player_hero", 40.0, &"player")
	_ensure_camera_follow(player_body)


func _spawn_enemy() -> void:
	if _enemies_root().get_node_or_null("InklingChaser") != null:
		return
	var enemy_data = _content_factory.inkling_chaser_enemy()
	var enemy_body := CharacterBody3D.new()
	enemy_body.name = "InklingChaser"
	enemy_body.set_script(ChaserEnemyScript)
	_enemies_root().add_child(enemy_body)
	enemy_body.global_position = Vector3(5.0, 0.0, 1.5)
	if enemy_body.has_method("configure"):
		enemy_body.configure(enemy_data, player())
	var health := _ensure_health(enemy_body, enemy_data.id, enemy_data.max_health, &"enemy")
	if enemy_body.has_method("set_health_component"):
		enemy_body.set_health_component(health)


func _ensure_weapon_manager() -> void:
	var manager := _projectiles_root().get_node_or_null("WeaponManager")
	if manager == null:
		manager = AutoWeaponManagerScript.new()
		manager.name = "WeaponManager"
		_projectiles_root().add_child(manager)
	if manager.has_method("configure"):
		manager.configure(player(), _enemies_root(), _damage_model, _content_factory.waxlight_comet_weapon())


func _ensure_health(owner: Node, entity_id: StringName, max_health: float, team_id: StringName) -> Node:
	var health := owner.get_node_or_null("HealthComponent")
	if health == null:
		health = HealthComponentScript.new()
		health.name = "HealthComponent"
		owner.add_child(health)
	if health.has_method("configure"):
		health.configure(entity_id, max_health, team_id)
	return health


func _on_entity_died(event: Dictionary) -> void:
	var target = event.get("target", null)
	if not target is Node:
		return
	var owner := (target as Node).get_parent()
	var reward := 0
	if owner != null and "reward_xp" in owner:
		reward = owner.reward_xp
	if reward <= 0:
		return
	_xp_total += reward
	if _event_bus != null and _event_bus.has_method("emit_xp_awarded"):
		_event_bus.emit_xp_awarded({
			"amount": reward,
			"total": _xp_total,
			"source_id": event.get("target_id", &"unknown_enemy"),
		})


func _ensure_camera_follow(target: Node3D) -> void:
	var camera_rig := _camera_rig()
	var follow := camera_rig.get_node_or_null("GameplayCameraFollow")
	if follow == null:
		follow = Node.new()
		follow.name = "GameplayCameraFollow"
		follow.set_script(GameplayCameraFollowScript)
		camera_rig.add_child(follow)
	if follow.has_method("configure"):
		follow.configure(target, camera_rig)


func _run_root() -> Node3D:
	return get_parent() as Node3D


func _players_root() -> Node3D:
	return _run_root().get_node("Actors/Players") as Node3D


func _enemies_root() -> Node3D:
	return _run_root().get_node("Actors/Enemies") as Node3D


func _projectiles_root() -> Node3D:
	return _run_root().get_node("Projectiles") as Node3D


func _camera() -> Camera3D:
	return _camera_rig().get_node("Camera3D") as Camera3D


func _camera_rig() -> Node3D:
	return _run_root().get_node("CameraRig") as Node3D


func _damage_numbers_root() -> Node3D:
	return _run_root().get_node("DamageNumbers") as Node3D
