class_name FirstPlayableRuntime
extends Node

const InputActionsScript := preload("res://src/input/input_actions.gd")
const DamageModelScript := preload("res://src/combat/damage_model.gd")
const DamageNumberManagerScript := preload("res://src/feedback/damage_number_manager.gd")
const GameplayCameraFollowScript := preload("res://src/camera/gameplay_camera_follow.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const PlayerControllerScript := preload("res://src/player/player_controller.gd")
const PagecraftManagerScript := preload("res://src/pagecraft/pagecraft_manager.gd")
const AutoWeaponManagerScript := preload("res://src/weapons/auto_weapon_manager.gd")
const RunDirectorScript := preload("res://src/runtime/run_director.gd")
const XpPickupScript := preload("res://src/pickups/xp_pickup.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")

@export var enable_first_playable_loop := true

var _input_actions = InputActionsScript.new()
var _content_factory = PrototypeContentFactoryScript.new()
var _damage_model = DamageModelScript.new()
var _event_bus: Node
var _xp_total := 0
var _contact_damage_cooldown_remaining := 0.0
var _hud_label: Label


func _ready() -> void:
	if not enable_first_playable_loop:
		return
	call_deferred("_start_first_playable_loop")


func _physics_process(delta: float) -> void:
	if not enable_first_playable_loop:
		return
	_tick_contact_damage(delta)
	_update_hud()


func _start_first_playable_loop() -> void:
	_input_actions.ensure_default_actions()
	_ensure_runtime_services()
	_ensure_damage_number_manager()
	_ensure_pagecraft_manager()
	_ensure_minimal_hud()
	_spawn_player()
	_ensure_run_director()
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


## Returns first-playable player health for smoke/debug checks.
func debug_player_health() -> float:
	var health := _player_health()
	if health == null or not "current_health" in health:
		return 0.0
	return health.current_health


## Returns first-playable player max health for smoke/debug checks.
func debug_player_max_health() -> float:
	var health := _player_health()
	if health == null or not "max_health" in health:
		return 0.0
	return health.max_health


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
	_ensure_health(player_body, &"player_hero", 50.0, &"player")
	_ensure_camera_follow(player_body)
	_connect_player_dash(player_body)


func _ensure_weapon_manager() -> void:
	var manager := _projectiles_root().get_node_or_null("WeaponManager")
	if manager == null:
		manager = AutoWeaponManagerScript.new()
		manager.name = "WeaponManager"
		_projectiles_root().add_child(manager)
	if manager.has_method("configure"):
		manager.configure(player(), _enemies_root(), _damage_model, _content_factory.waxlight_comet_weapon(), _pagecraft_manager())


func _ensure_run_director() -> void:
	var director := _run_root().get_node_or_null("RunDirector")
	if director == null:
		director = RunDirectorScript.new()
		director.name = "RunDirector"
		_run_root().add_child(director)
	if director.has_method("configure"):
		director.configure(_enemies_root(), player(), _content_factory, Vector2(7.7, 4.7))


func _ensure_pagecraft_manager() -> void:
	var manager := _pagecraft_root().get_node_or_null("PagecraftManager")
	if manager == null:
		manager = PagecraftManagerScript.new()
		manager.name = "PagecraftManager"
		_pagecraft_root().add_child(manager)
	if manager.has_method("configure"):
		manager.configure(_event_bus, _pagecraft_root())


func _connect_player_dash(player_body: Node) -> void:
	var manager := _pagecraft_manager()
	if player_body == null or manager == null or not player_body.has_signal("dash_path_sampled"):
		return
	var callable := Callable(manager, "activate_path")
	if not player_body.dash_path_sampled.is_connected(callable):
		player_body.dash_path_sampled.connect(callable)


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
	_show_enemy_death(owner)
	var reward := 0
	if owner != null and "reward_xp" in owner:
		reward = owner.reward_xp
	if reward <= 0:
		return
	_spawn_xp_pickup(_event_position(event), reward)
	_update_hud()


func _on_xp_pickup_collected(_pickup: Node, amount: int) -> void:
	_xp_total += amount
	if _event_bus != null and _event_bus.has_method("emit_xp_awarded"):
		_event_bus.emit_xp_awarded({
			"amount": amount,
			"total": _xp_total,
			"source_id": &"color_mote",
		})
	_update_hud()


func _tick_contact_damage(delta: float) -> void:
	_contact_damage_cooldown_remaining = maxf(0.0, _contact_damage_cooldown_remaining - delta)
	if _contact_damage_cooldown_remaining > 0.0:
		return
	var player_health := _player_health()
	if player_health == null or not player_health.has_method("is_alive") or not player_health.is_alive():
		return
	for enemy in _enemies_root().get_children():
		if not enemy is Node3D or not enemy.visible:
			continue
		var enemy_health := enemy.get_node_or_null("HealthComponent")
		if enemy_health == null or not enemy_health.has_method("is_alive") or not enemy_health.is_alive():
			continue
		if player().global_position.distance_to((enemy as Node3D).global_position) <= 0.85:
			_damage_model.apply_damage(player_health, enemy.name, enemy.contact_damage, [&"contact"])
			_contact_damage_cooldown_remaining = 0.7
			_update_hud()
			return


func _ensure_minimal_hud() -> void:
	var hud := _hud()
	hud.visible = true
	_hud_label = hud.get_node_or_null("FirstPlayableHudLabel") as Label
	if _hud_label == null:
		_hud_label = Label.new()
		_hud_label.name = "FirstPlayableHudLabel"
		_hud_label.position = Vector2(16.0, 12.0)
		_hud_label.add_theme_font_size_override("font_size", 22)
		hud.add_child(_hud_label)
	_update_hud()


func _update_hud() -> void:
	if _hud_label == null:
		return
	_hud_label.text = "HP: %d/%d  XP: %d" % [
		roundi(debug_player_health()),
		roundi(debug_player_max_health()),
		_xp_total,
	]


func _show_enemy_death(owner: Node) -> void:
	if owner == null:
		return
	owner.visible = false
	owner.set_physics_process(false)
	var collision := owner.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null:
		collision.disabled = true


func _spawn_xp_pickup(world_position: Vector3, amount: int) -> void:
	var pickup := XpPickupScript.new()
	pickup.name = "ColorMote_%d" % amount
	pickup.position = Vector3(world_position.x, 0.28, world_position.z)
	_pickups_root().add_child(pickup)
	if pickup.has_method("configure"):
		pickup.configure(amount, player())
	if pickup.has_signal("collected") and not pickup.collected.is_connected(_on_xp_pickup_collected):
		pickup.collected.connect(_on_xp_pickup_collected)


func _event_position(event: Dictionary) -> Vector3:
	return event.get("world_position", Vector3.ZERO)


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


func _player_health() -> Node:
	var player_node := player()
	if player_node == null:
		return null
	return player_node.get_node_or_null("HealthComponent")


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


func _pickups_root() -> Node3D:
	return _run_root().get_node("Pickups") as Node3D


func _hud() -> Control:
	return get_parent().get_parent().get_node("UI/HUD") as Control


func _pagecraft_root() -> Node3D:
	return _run_root().get_node("Pagecraft") as Node3D


func _pagecraft_manager() -> Node:
	return _pagecraft_root().get_node_or_null("PagecraftManager")
