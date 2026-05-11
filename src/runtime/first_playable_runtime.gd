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
const RunDraftControllerScript := preload("res://src/runtime/run_draft_controller.gd")
const RunLevelTrackerScript := preload("res://src/runtime/run_level_tracker.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")
const XpPickupScript := preload("res://src/pickups/xp_pickup.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")
const CAMERA_LOCAL_POSITION := Vector3(0.0, 9.0, 4.4)
const CAMERA_FOLLOW_HALF_EXTENTS := Vector2(3.8, 2.3)
const CAMERA_FOV_DEGREES := 61.0

@export var enable_first_playable_loop := true

var _input_actions = InputActionsScript.new()
var _content_factory = PrototypeContentFactoryScript.new()
var _damage_model = DamageModelScript.new()
var _level_tracker = RunLevelTrackerScript.new()
var _upgrade_state = RunUpgradeStateScript.new()
var _event_bus: Node
var _draft_controller: Node
var _contact_damage_cooldown_remaining := 0.0
var _run_ended := false
var _hud_label: Label


func _ready() -> void:
	if not enable_first_playable_loop:
		return
	call_deferred("_start_first_playable_loop")


func _physics_process(delta: float) -> void:
	if not enable_first_playable_loop:
		return
	if _run_ended:
		return
	_tick_contact_damage(delta)
	_update_hud()


func _start_first_playable_loop() -> void:
	_input_actions.ensure_default_actions()
	_ensure_runtime_services()
	_ensure_damage_number_manager()
	_ensure_pagecraft_manager()
	_ensure_minimal_hud()
	_ensure_draft_controller()
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
	return _level_tracker.total_xp()


## Returns first-playable run level for smoke/debug checks.
func debug_run_level() -> int:
	return _level_tracker.run_level()


## Returns XP progress within current run level.
func debug_current_level_xp() -> int:
	return _level_tracker.current_level_xp()


## Returns XP needed for the next run level.
func debug_xp_threshold() -> int:
	return _level_tracker.xp_threshold_for_next_level()


## Returns count of emitted level-ups for smoke/debug checks.
func debug_level_up_count() -> int:
	return _level_tracker.level_up_count()


## Spawns a Color Mote for smoke checks.
func debug_spawn_xp_pickup(world_position: Vector3, amount: int) -> void:
	_spawn_xp_pickup(world_position, amount)


## Returns true after player death/victory ends the run.
func debug_run_ended() -> bool:
	return _run_ended


## Returns true while prototype draft UI is open.
func debug_draft_is_open() -> bool:
	return _draft_controller != null and _draft_controller.has_method("is_draft_open") and _draft_controller.is_draft_open()


## Returns current prototype draft choice count.
func debug_draft_choice_count() -> int:
	if _draft_controller == null or not _draft_controller.has_method("debug_choice_count"):
		return 0
	return _draft_controller.debug_choice_count()


## Accepts the focused/default draft choice for smoke checks.
func debug_accept_focused_draft_choice() -> void:
	if _draft_controller != null and _draft_controller.has_method("accept_focused_choice"):
		_draft_controller.accept_focused_choice()


## Focuses a draft choice for smoke checks.
func debug_focus_draft_choice_index(choice_index: int) -> void:
	if _draft_controller != null and _draft_controller.has_method("focus_choice_index"):
		_draft_controller.focus_choice_index(choice_index)


## Returns last selected draft choice ID for smoke checks.
func debug_selected_draft_choice_id() -> StringName:
	if _draft_controller == null or not _draft_controller.has_method("debug_selected_choice_id"):
		return &""
	return _draft_controller.debug_selected_choice_id()


## Applies a prototype upgrade choice for smoke/debug checks.
func debug_apply_upgrade_choice(choice_id: StringName) -> void:
	_apply_upgrade_choice(choice_id)


## Returns current Waxlight damage bonus.
func debug_waxlight_damage_bonus() -> float:
	return _upgrade_state.waxlight_damage_bonus()


## Returns current Waxlight cooldown multiplier.
func debug_waxlight_cooldown_multiplier() -> float:
	return _upgrade_state.waxlight_cooldown_multiplier()


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
	if _event_bus.has_signal("draft_choice_selected") and not _event_bus.draft_choice_selected.is_connected(_on_draft_choice_selected):
		_event_bus.draft_choice_selected.connect(_on_draft_choice_selected)
	_level_tracker.configure(_event_bus)


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
	_configure_gameplay_camera()
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
		manager.configure(player(), _enemies_root(), _damage_model, _content_factory.waxlight_comet_weapon(), _pagecraft_manager(), _upgrade_state)


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
		manager.configure(_event_bus, _pagecraft_root(), _damage_model, _enemies_root(), _upgrade_state)


func _ensure_draft_controller() -> void:
	_draft_controller = _run_root().get_node_or_null("RunDraftController")
	if _draft_controller == null:
		_draft_controller = RunDraftControllerScript.new()
		_draft_controller.name = "RunDraftController"
		_run_root().add_child(_draft_controller)
	if _draft_controller.has_method("configure"):
		_draft_controller.configure(_event_bus, _modal_layer(), _level_up_screen(), _upgrade_state)


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
	if owner == player():
		_end_run_from_player_death(event)
		return
	_show_enemy_death(owner)
	var reward := 0
	if owner != null and "reward_xp" in owner:
		reward = owner.reward_xp
	if reward <= 0:
		return
	_spawn_xp_pickup(_event_position(event), reward)
	_update_hud()


func _on_xp_pickup_collected(_pickup: Node, amount: int) -> void:
	if _run_ended:
		return
	_level_tracker.add_xp(amount, &"color_mote")
	_update_hud()


func _on_draft_choice_selected(event: Dictionary) -> void:
	_apply_upgrade_choice(event.get("choice_id", &""))


func _apply_upgrade_choice(choice_id: StringName) -> void:
	if _run_ended:
		return
	var upgrade_event := _upgrade_state.apply_choice(choice_id)
	if upgrade_event.is_empty():
		return
	_apply_player_upgrade_effects(upgrade_event)
	_refresh_weapon_runtime_modifiers()
	if _event_bus != null and _event_bus.has_method("emit_upgrade_applied"):
		_event_bus.emit_upgrade_applied(upgrade_event)
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
		_hud_label.custom_minimum_size = Vector2(240.0, 96.0)
		_hud_label.add_theme_font_size_override("font_size", 22)
		_hud_label.add_theme_color_override("font_color", Color(0.04, 0.035, 0.03, 1.0))
		_hud_label.add_theme_color_override("font_outline_color", Color(1.0, 0.96, 0.86, 0.85))
		_hud_label.add_theme_constant_override("outline_size", 3)
		hud.add_child(_hud_label)
	_ensure_death_screen()
	_update_hud()


func _update_hud() -> void:
	if _hud_label == null:
		return
	_hud_label.text = "HP: %d/%d\nLevel: %d\nXP: %d/%d\nEnemies: %d/%d\nBudget: %d\nSpawned: %d\nTime: %s" % [
		roundi(debug_player_health()),
		roundi(debug_player_max_health()),
		debug_run_level(),
		debug_current_level_xp(),
		debug_xp_threshold(),
		_active_enemy_count(),
		_enemy_budget(),
		_enemy_budget(),
		_spawned_count(),
		_format_run_time(_run_time_seconds()),
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
	if _run_ended:
		return
	var pickup := XpPickupScript.new()
	pickup.name = "ColorMote_%d" % amount
	pickup.position = Vector3(world_position.x, 0.28, world_position.z)
	_pickups_root().add_child(pickup)
	if pickup.has_method("configure"):
		pickup.configure(amount, player())
	if pickup.has_signal("collected") and not pickup.collected.is_connected(_on_xp_pickup_collected):
		pickup.collected.connect(_on_xp_pickup_collected)


func _apply_player_upgrade_effects(upgrade_event: Dictionary) -> void:
	var max_health_delta := float(upgrade_event.get("player_max_health_delta", 0.0))
	if max_health_delta == 0.0:
		return
	var health := _player_health()
	if health != null and health.has_method("add_max_health"):
		health.add_max_health(max_health_delta, true)


func _refresh_weapon_runtime_modifiers() -> void:
	var manager := _projectiles_root().get_node_or_null("WeaponManager")
	if manager != null and manager.has_method("refresh_runtime_modifiers"):
		manager.refresh_runtime_modifiers()


func _end_run_from_player_death(event: Dictionary) -> void:
	if _run_ended:
		return
	_run_ended = true
	if _draft_controller != null and _draft_controller.has_method("force_close"):
		_draft_controller.force_close(true)
	_show_death_screen()
	if _event_bus != null and _event_bus.has_method("emit_run_ended"):
		_event_bus.emit_run_ended({
			"reason": &"player_died",
			"world_position": _event_position(event),
		})
	if get_tree() != null:
		get_tree().paused = true


func _ensure_death_screen() -> void:
	if _modal_layer().get_node_or_null("DeathScreen") != null:
		return
	var death_screen := Control.new()
	death_screen.name = "DeathScreen"
	death_screen.visible = false
	death_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	death_screen.layout_mode = 1
	death_screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	_modal_layer().add_child(death_screen)

	var label := Label.new()
	label.name = "DeathLabel"
	label.text = "Run Over"
	label.position = Vector2(320.0, 180.0)
	label.add_theme_font_size_override("font_size", 36)
	label.add_theme_color_override("font_color", Color(0.05, 0.035, 0.03, 1.0))
	label.add_theme_color_override("font_outline_color", Color(1.0, 0.9, 0.78, 0.92))
	label.add_theme_constant_override("outline_size", 4)
	death_screen.add_child(label)


func _show_death_screen() -> void:
	var modal := _modal_layer()
	var screen := modal.get_node_or_null("DeathScreen") as Control
	if screen == null:
		_ensure_death_screen()
		screen = modal.get_node_or_null("DeathScreen") as Control
	modal.visible = true
	if screen != null:
		screen.visible = true


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
	if "page_half_extents" in follow:
		follow.page_half_extents = CAMERA_FOLLOW_HALF_EXTENTS


func _configure_gameplay_camera() -> void:
	var camera := _camera()
	camera.position = CAMERA_LOCAL_POSITION
	camera.fov = CAMERA_FOV_DEGREES
	camera.look_at(_camera_rig().global_position, Vector3.UP)


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


func _modal_layer() -> Control:
	return get_parent().get_parent().get_node("UI/ModalLayer") as Control


func _level_up_screen() -> Control:
	return get_parent().get_parent().get_node("UI/ModalLayer/LevelUpScreen") as Control


func _pagecraft_root() -> Node3D:
	return _run_root().get_node("Pagecraft") as Node3D


func _pagecraft_manager() -> Node:
	return _pagecraft_root().get_node_or_null("PagecraftManager")


func _run_director() -> Node:
	return _run_root().get_node_or_null("RunDirector")


func _active_enemy_count() -> int:
	var director := _run_director()
	if director != null and director.has_method("debug_active_enemy_count"):
		return director.debug_active_enemy_count()
	return 0


func _enemy_budget() -> int:
	var director := _run_director()
	if director != null and director.has_method("debug_active_budget"):
		return director.debug_active_budget()
	return 0


func _spawned_count() -> int:
	var director := _run_director()
	if director != null and director.has_method("debug_spawned_count"):
		return director.debug_spawned_count()
	return 0


func _run_time_seconds() -> float:
	var director := _run_director()
	if director != null and director.has_method("debug_run_time"):
		return director.debug_run_time()
	return 0.0


func _format_run_time(total_seconds: float) -> String:
	var whole_seconds := maxi(0, floori(total_seconds))
	var minutes := whole_seconds / 60
	var seconds := whole_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
