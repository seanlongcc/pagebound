class_name FirstPlayableRuntime
extends Node

const InputActionsScript := preload("res://src/input/input_actions.gd")
const DamageModelScript := preload("res://src/combat/damage_model.gd")
const DamageNumberManagerScript := preload("res://src/feedback/damage_number_manager.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const PlayerControllerScript := preload("res://src/player/player_controller.gd")
const PagecraftManagerScript := preload("res://src/pagecraft/pagecraft_manager.gd")
const AutoWeaponManagerScript := preload("res://src/weapons/auto_weapon_manager.gd")
const FirstPlayableCameraControllerScript := preload("res://src/runtime/first_playable_camera_controller.gd")
const FirstPlayablePageEventOrchestratorScript := preload("res://src/runtime/first_playable_page_event_orchestrator.gd")
const FirstPlayableRunUiScript := preload("res://src/runtime/first_playable_run_ui.gd")
const DogSupportPetScript := preload("res://src/runtime/dog_support_pet.gd")
const CrownlessEchoControllerScript := preload("res://src/runtime/crownless_echo_controller.gd")
const RunDirectorScript := preload("res://src/runtime/run_director.gd")
const RunDraftControllerScript := preload("res://src/runtime/run_draft_controller.gd")
const RunLevelTrackerScript := preload("res://src/runtime/run_level_tracker.gd")
const RunMenuControllerScript := preload("res://src/runtime/run_menu_controller.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")
const XpPickupScript := preload("res://src/pickups/xp_pickup.gd")
const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RuntimeEventBusScript := preload("res://src/events/runtime_event_bus.gd")
const PAGE_HALF_EXTENTS := Vector2(32.0, 20.0)

@export var enable_first_playable_loop := true

var _input_actions = InputActionsScript.new()
var _camera_controller = FirstPlayableCameraControllerScript.new()
var _content_factory = PrototypeContentFactoryScript.new()
var _damage_model = DamageModelScript.new()
var _level_tracker = RunLevelTrackerScript.new()
var _page_event_orchestrator = FirstPlayablePageEventOrchestratorScript.new()
var _boss_controller = CrownlessEchoControllerScript.new()
var _run_ui = FirstPlayableRunUiScript.new()
var _upgrade_state = RunUpgradeStateScript.new()
var _event_bus: Node
var _draft_controller: Node
var _menu_controller: Node
var _contact_damage_cooldown_remaining := 0.0
var _run_started := false
var _run_ended := false
var _enemies_defeated := 0
var _dog_feedback_text := "Dog"
var _dog_feedback_remaining := 0.0


func _ready() -> void:
	if not enable_first_playable_loop:
		return
	call_deferred("_initialize_first_playable_loop")


func _physics_process(delta: float) -> void:
	if not enable_first_playable_loop:
		return
	if not _run_started or _run_ended:
		return
	_tick_contact_damage(delta)
	_tick_dog_feedback(delta)
	_page_event_orchestrator.tick(_run_time_seconds(), delta, _run_director())
	_boss_controller.tick(_run_time_seconds(), _page_event_orchestrator.is_active())
	_check_vertical_slice_end()
	_update_hud()


func _initialize_first_playable_loop() -> void:
	_input_actions.ensure_default_actions()
	_upgrade_state.configure(_content_factory)
	_ensure_runtime_services()
	_ensure_damage_number_manager()
	_ensure_pagecraft_manager()
	_ensure_minimal_hud()
	_run_ui.set_hud_visible(false)
	_ensure_page_event_orchestrator()
	_ensure_draft_controller()
	_ensure_menu_controller()
	if _menu_controller != null and _menu_controller.has_method("show_start_menu"):
		_menu_controller.show_start_menu()


func _start_run() -> void:
	_prepare_clean_run_state()
	_run_started = true
	_run_ended = false
	_enemies_defeated = 0
	if get_tree() != null:
		get_tree().paused = false
	_ensure_runtime_services()
	_ensure_damage_number_manager()
	_ensure_pagecraft_manager()
	_ensure_minimal_hud()
	_ensure_page_event_orchestrator()
	_ensure_draft_controller()
	_spawn_player()
	_ensure_dog_pet()
	_ensure_boss_controller()
	_ensure_run_director()
	_ensure_weapon_manager()
	_run_ui.set_hud_visible(true)
	if _menu_controller != null and _menu_controller.has_method("hide_all"):
		_menu_controller.hide_all()
	var director := _run_director()
	if director != null and director.has_method("start"):
		director.start()
	if player() != null:
		player().global_position = Vector3.ZERO
		if player().has_method("reset_to_spawn_position"):
			player().reset_to_spawn_position(Vector3.ZERO)
		_camera_controller.ensure_follow(player(), _camera_rig())
		_camera_controller.snap_to_target(player(), _camera_rig(), _camera())
	_update_hud()


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


## Returns true only while gameplay systems are running.
func debug_run_started() -> bool:
	return _run_started


## Starts the run from start menu for smoke/debug checks.
func debug_start_run() -> void:
	_start_run()


## Retries the run from death/victory menus for smoke/debug checks.
func debug_retry_run() -> void:
	_start_run()


## Returns to idle start menu for smoke/debug checks.
func debug_return_to_main_menu() -> void:
	_return_to_main_menu()


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


## Focuses a visible draft choice by ID for smoke checks.
func debug_focus_draft_choice_id(choice_id: StringName) -> void:
	if _draft_controller != null and _draft_controller.has_method("focus_choice_id"):
		_draft_controller.focus_choice_id(choice_id)


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


## Returns currently owned weapon IDs for smoke/debug checks.
func debug_owned_weapon_ids() -> Array[StringName]:
	if _upgrade_state.has_method("owned_weapon_ids"):
		return _upgrade_state.owned_weapon_ids()
	return []


## Returns currently owned passive IDs for smoke/debug checks.
func debug_owned_passive_ids() -> Array[StringName]:
	if _upgrade_state.has_method("owned_passive_ids"):
		return _upgrade_state.owned_passive_ids()
	return []


## Returns enemy defeat count for summary smoke checks.
func debug_enemies_defeated() -> int:
	return _enemies_defeated


## Kills the player through normal damage flow for smoke checks.
func debug_kill_player() -> void:
	var health := _player_health()
	if health != null:
		_damage_model.apply_damage(health, &"debug_kill", 99999.0, [&"debug"])


## Forces director run time and timeline checks for smoke tests.
func debug_force_run_time(seconds: float) -> void:
	var director := _run_director()
	if director != null and director.has_method("debug_force_run_time"):
		director.debug_force_run_time(seconds)
	_page_event_orchestrator.tick(seconds, 0.0, director)
	_boss_controller.tick(seconds, _page_event_orchestrator.is_active())
	_update_hud()


## Returns active or resolved Page Event ID for smoke checks.
func debug_active_page_event_id() -> StringName:
	return _page_event_orchestrator.active_event_id()


## Returns structured Color Well state for smoke/debug checks.
func debug_page_event_state() -> Dictionary:
	return _page_event_orchestrator.debug_state()


## Adds a debug enemy-death position to the active Color Well objective.
func debug_add_page_event_kill(death_position: Vector3) -> void:
	_page_event_orchestrator.add_kill_progress(death_position)
	_update_hud()


## Advances only the active Page Event timer for smoke checks.
func debug_advance_page_event(delta: float) -> void:
	_page_event_orchestrator.advance_time(delta)
	_boss_controller.tick(_run_time_seconds(), _page_event_orchestrator.is_active())
	_update_hud()


## Returns Crownless Echo state for smoke/debug checks.
func debug_boss_state() -> Dictionary:
	return _boss_controller.state()


## Applies direct debug damage to Crownless Echo.
func debug_damage_boss(amount: float) -> void:
	_boss_controller.damage_boss(amount)
	_update_hud()


## Returns Dog assist aura radius for smoke/debug checks.
func debug_dog_aura_radius() -> float:
	var dog := _dog_pet()
	if dog != null and dog.has_method("aura_radius"):
		return dog.aura_radius()
	return 0.0


## Sets Dog support tier for smoke/debug checks.
func debug_set_dog_tier(tier: int) -> void:
	var dog := _dog_pet()
	if dog != null and dog.has_method("set_tier"):
		dog.set_tier(tier)
	_update_hud()


## Returns whether Dog accepts a pickup type at its current tier.
func debug_dog_accepts_pickup_type(pickup_type: StringName) -> bool:
	var dog := _dog_pet()
	return dog != null and dog.has_method("accepts_pickup_type") and dog.accepts_pickup_type(pickup_type)


## Returns current Dog HUD feedback text.
func debug_dog_feedback_text() -> String:
	return _dog_feedback_text


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
	if "page_half_extents" in player_body:
		player_body.page_half_extents = PAGE_HALF_EXTENTS
	_camera_controller.configure_camera(_camera(), _camera_rig())
	if player_body.has_method("set_follow_camera"):
		player_body.set_follow_camera(_camera())
	_ensure_health(player_body, &"player_hero", 50.0, &"player")
	_camera_controller.ensure_follow(player_body, _camera_rig())
	_connect_player_dash(player_body)


func _ensure_weapon_manager() -> void:
	var manager := _projectiles_root().get_node_or_null("WeaponManager")
	if manager == null:
		manager = AutoWeaponManagerScript.new()
		manager.name = "WeaponManager"
		_projectiles_root().add_child(manager)
	if manager.has_method("configure"):
		manager.configure(player(), _enemies_root(), _damage_model, _content_factory.waxlight_comet_weapon(), _pagecraft_manager(), _upgrade_state, _content_factory)


func _ensure_dog_pet() -> void:
	var dog := _dog_pet()
	if dog == null:
		dog = DogSupportPetScript.new()
		dog.name = "Dog"
		_pets_root().add_child(dog)
	if dog.has_method("configure"):
		dog.configure(player(), _pickups_root())
	if dog.has_signal("pickup_assisted") and not dog.pickup_assisted.is_connected(_on_dog_pickup_assisted):
		dog.pickup_assisted.connect(_on_dog_pickup_assisted)


func _ensure_boss_controller() -> void:
	_boss_controller.configure(_enemies_root(), player(), _damage_model, PAGE_HALF_EXTENTS)


func _ensure_run_director() -> void:
	var director := _run_root().get_node_or_null("RunDirector")
	if director == null:
		director = RunDirectorScript.new()
		director.name = "RunDirector"
		_run_root().add_child(director)
	if director.has_method("configure"):
		director.configure(_enemies_root(), player(), _content_factory, PAGE_HALF_EXTENTS)


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
		_draft_controller.configure(_event_bus, _modal_layer(), _level_up_screen(), _upgrade_state, _hud())


func _ensure_menu_controller() -> void:
	_menu_controller = _run_root().get_node_or_null("RunMenuController")
	if _menu_controller == null:
		_menu_controller = RunMenuControllerScript.new()
		_menu_controller.name = "RunMenuController"
		_run_root().add_child(_menu_controller)
	if _menu_controller.has_method("configure"):
		_menu_controller.configure(_modal_layer())
	if _menu_controller.has_signal("start_requested") and not _menu_controller.start_requested.is_connected(_start_run):
		_menu_controller.start_requested.connect(_start_run)
	if _menu_controller.has_signal("retry_requested") and not _menu_controller.retry_requested.is_connected(_start_run):
		_menu_controller.retry_requested.connect(_start_run)
	if _menu_controller.has_signal("main_menu_requested") and not _menu_controller.main_menu_requested.is_connected(_return_to_main_menu):
		_menu_controller.main_menu_requested.connect(_return_to_main_menu)


func _ensure_page_event_orchestrator() -> void:
	_page_event_orchestrator.ensure(_run_root(), _hud(), player(), PAGE_HALF_EXTENTS)
	if not _page_event_orchestrator.event_completed.is_connected(_on_page_event_completed):
		_page_event_orchestrator.event_completed.connect(_on_page_event_completed)


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
	_enemies_defeated += 1
	_page_event_orchestrator.add_kill_progress(_event_position(event))
	var reward := 0
	if owner != null and "reward_xp" in owner:
		reward = owner.reward_xp
	if reward <= 0:
		return
	_spawn_xp_pickup(_event_position(event), reward)
	_update_hud()


func _on_xp_pickup_collected(_pickup: Node, amount: int) -> void:
	if not _run_started or _run_ended:
		return
	_level_tracker.add_xp(amount, &"color_mote")
	_update_hud()


func _on_dog_pickup_assisted(amount: int, pickup_type: StringName, _world_position: Vector3) -> void:
	if pickup_type == &"color_mote":
		_dog_feedback_text = "Dog fetch +%d XP" % amount
	else:
		_dog_feedback_text = "Dog fetch"
	_dog_feedback_remaining = 1.0
	_update_hud()


func _on_page_event_completed(event: Dictionary) -> void:
	if _draft_controller != null and _draft_controller.has_method("open_page_event_reward"):
		_draft_controller.open_page_event_reward(event)
	_update_hud()


func _on_draft_choice_selected(event: Dictionary) -> void:
	_apply_upgrade_choice(event.get("choice_id", &""))


func _apply_upgrade_choice(choice_id: StringName) -> void:
	if not _run_started or _run_ended:
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
			if not "contact_damage" in enemy:
				continue
			_damage_model.apply_damage(player_health, enemy.name, enemy.contact_damage, [&"contact"])
			_contact_damage_cooldown_remaining = 0.7
			_update_hud()
			return


func _tick_dog_feedback(delta: float) -> void:
	if _dog_feedback_remaining <= 0.0:
		return
	_dog_feedback_remaining = maxf(0.0, _dog_feedback_remaining - delta)
	if _dog_feedback_remaining <= 0.0:
		_dog_feedback_text = "Dog"
		_update_hud()


func _ensure_minimal_hud() -> void:
	_run_ui.ensure_hud(_hud())
	_update_hud()


func _update_hud() -> void:
	_run_ui.update_hud(_run_ui_context())


func _run_ui_context() -> Dictionary:
	return {
		"player_health": debug_player_health(),
		"player_max_health": debug_player_max_health(),
		"run_level": debug_run_level(),
		"current_level_xp": debug_current_level_xp(),
		"xp_threshold": debug_xp_threshold(),
		"run_time_seconds": _run_time_seconds(),
		"waxlight_damage": _waxlight_damage_value(),
		"waxlight_cooldown_seconds": _waxlight_cooldown_value(),
		"waxlight_duration_seconds": _waxlight_duration_value(),
		"waxlight_cap": _waxlight_cap_value(),
		"waxlight_unactivated_count": _waxlight_unactivated_count(),
		"waxlight_active_count": _waxlight_active_count(),
		"director_spawn_rate": _director_spawn_rate(),
		"director_band": _director_band(),
		"enemy_budget": _enemy_budget(),
		"spawned_count": _spawned_count(),
		"active_enemy_count": _active_enemy_count(),
		"safety_enemy_cap": _safety_enemy_cap(),
		"page_event_line": _page_event_orchestrator.hud_line(),
		"page_event_state": _page_event_orchestrator.debug_state(),
		"boss_state": _boss_controller.state(),
		"weapon_ids": debug_owned_weapon_ids(),
		"passive_ids": debug_owned_passive_ids(),
		"dog_feedback_text": _dog_feedback_text,
		"dog_tier": _dog_tier(),
		"xp_total": debug_xp_total(),
		"enemies_defeated": _enemies_defeated,
	}


func _show_enemy_death(owner: Node) -> void:
	if owner == null:
		return
	owner.visible = false
	owner.set_physics_process(false)
	var collision := owner.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null:
		collision.disabled = true


func _spawn_xp_pickup(world_position: Vector3, amount: int) -> void:
	if not _run_started or _run_ended:
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
	_run_started = false
	if _draft_controller != null and _draft_controller.has_method("force_close"):
		_draft_controller.force_close(true)
	var director := _run_director()
	if director != null and director.has_method("stop"):
		director.stop()
	if _menu_controller != null and _menu_controller.has_method("show_death_menu"):
		_menu_controller.show_death_menu()
	if _event_bus != null and _event_bus.has_method("emit_run_ended"):
		_event_bus.emit_run_ended({
			"reason": &"player_died",
			"world_position": _event_position(event),
		})
	if get_tree() != null:
		get_tree().paused = true


func _prepare_clean_run_state() -> void:
	_clear_children(_players_root())
	_clear_children(_pets_root())
	_clear_children(_enemies_root())
	_clear_children(_pickups_root())
	_clear_children(_projectiles_root())
	var pagecraft := _pagecraft_manager()
	if pagecraft != null and pagecraft.has_method("debug_clear_marks"):
		pagecraft.debug_clear_marks()
	_contact_damage_cooldown_remaining = 0.0
	_level_tracker.reset()
	_upgrade_state.reset()
	_boss_controller.reset()
	_dog_feedback_text = "Dog"
	_dog_feedback_remaining = 0.0
	_page_event_orchestrator.reset()
	var director := _run_director()
	if director != null and director.has_method("reset"):
		director.reset()
	_camera_controller.clear_follow(_camera_rig())


func _clear_children(root: Node) -> void:
	if root == null:
		return
	for child in root.get_children():
		root.remove_child(child)
		child.queue_free()


func _return_to_main_menu() -> void:
	_run_started = false
	_run_ended = false
	if get_tree() != null:
		get_tree().paused = false
	var director := _run_director()
	if director != null and director.has_method("stop"):
		director.stop()
	_prepare_clean_run_state()
	_run_ui.set_hud_visible(false)
	if _menu_controller != null and _menu_controller.has_method("show_start_menu"):
		_menu_controller.show_start_menu()


func _check_vertical_slice_end() -> void:
	pass


func _show_victory_summary() -> void:
	if _run_ended:
		return
	_run_ended = true
	_run_started = false
	var director := _run_director()
	if director != null and director.has_method("stop"):
		director.stop()
	if _draft_controller != null and _draft_controller.has_method("force_close"):
		_draft_controller.force_close(true)
	if _event_bus != null and _event_bus.has_method("emit_run_ended"):
		_event_bus.emit_run_ended({
			"reason": &"vertical_slice_complete",
			"world_position": Vector3.ZERO,
		})
	var summary_lines := _run_ui.summary_lines(_run_ui_context())
	if _menu_controller != null and _menu_controller.has_method("show_summary"):
		_menu_controller.show_summary(summary_lines)
	if get_tree() != null:
		get_tree().paused = true


func _waxlight_damage_value() -> float:
	var manager := _projectiles_root().get_node_or_null("WeaponManager")
	if manager != null and manager.has_method("debug_weapon_damage"):
		return manager.debug_weapon_damage(&"waxlight_comet")
	return _content_factory.waxlight_comet_weapon().level_data_for(1).base_damage


func _waxlight_cooldown_value() -> float:
	var manager := _projectiles_root().get_node_or_null("WeaponManager")
	if manager != null and manager.has_method("debug_cooldown_seconds"):
		return manager.debug_cooldown_seconds()
	return _content_factory.waxlight_comet_weapon().level_data_for(1).cooldown_seconds


func _waxlight_duration_value() -> float:
	var pagecraft := _pagecraft_manager()
	if pagecraft != null and pagecraft.has_method("debug_activation_duration_seconds"):
		return pagecraft.debug_activation_duration_seconds()
	return 0.0


func _waxlight_cap_value() -> int:
	var pagecraft := _pagecraft_manager()
	if pagecraft != null and pagecraft.has_method("debug_unactivated_mark_cap"):
		return pagecraft.debug_unactivated_mark_cap()
	return 0


func _waxlight_unactivated_count() -> int:
	var pagecraft := _pagecraft_manager()
	if pagecraft != null and pagecraft.has_method("debug_unactivated_mark_count"):
		return pagecraft.debug_unactivated_mark_count()
	return 0


func _waxlight_active_count() -> int:
	var pagecraft := _pagecraft_manager()
	if pagecraft != null and pagecraft.has_method("debug_active_mark_count"):
		return pagecraft.debug_active_mark_count()
	return 0


func _director_spawn_rate() -> float:
	var director := _run_director()
	if director != null and director.has_method("debug_spawn_rate_per_second"):
		return director.debug_spawn_rate_per_second()
	return 0.0


func _director_band() -> StringName:
	var director := _run_director()
	if director != null and director.has_method("debug_current_time_band_id"):
		return director.debug_current_time_band_id()
	return &"idle"


func _safety_enemy_cap() -> int:
	var director := _run_director()
	if director != null and director.has_method("debug_safety_enemy_cap"):
		return director.debug_safety_enemy_cap()
	return 0


func _event_position(event: Dictionary) -> Vector3:
	return event.get("world_position", Vector3.ZERO)


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


func _pets_root() -> Node3D:
	return _run_root().get_node("Actors/Pets") as Node3D


func _dog_pet() -> Node:
	return _pets_root().get_node_or_null("Dog")


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


func _dog_tier() -> int:
	var dog := _dog_pet()
	if dog != null and "tier" in dog:
		return int(dog.tier)
	return 1
