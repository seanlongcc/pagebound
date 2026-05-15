class_name RunDirector
extends Node

const ChaserEnemyScript := preload("res://src/enemies/chaser_enemy.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")

const TARGET_RUN_MINUTES := 30.0
const START_KILLS_PER_SECOND := 1.0
const END_KILLS_PER_SECOND := 10.0
const OPENING_MIN_ALIVE_START := 8
const OPENING_GRACE_SECONDS := 60.0
const MIN_ALIVE_START := 25
const MIN_ALIVE_END := 320
const SPAWN_INTERVAL_START := 1.0
const SPAWN_INTERVAL_END := 0.2
const AVERAGE_XP_MULTIPLIER_START := 1.0
const AVERAGE_XP_MULTIPLIER_END := 1.8
const BASE_ENEMY_XP := 5.0
const HEALTH_MULTIPLIER_END := 10.0

@export_range(1, 1000, 1) var safety_enemy_cap := 350
@export_range(1, 512, 1) var active_budget := OPENING_MIN_ALIVE_START
@export_range(0.1, 60.0, 0.05) var spawn_interval_seconds := SPAWN_INTERVAL_START
@export_range(1, 16, 1) var spawn_batch_size := 1
@export var page_half_extents := Vector2(11.0, 7.0)

var _enemies_root: Node3D
var _target: Node3D
var _content_factory
var _spawn_timer := 0.0
var _run_time := 0.0
var _spawned_count := 0
var _current_time_band_id: StringName = &"opening"
var _spawned_enemy_ids: Array[StringName] = []
var _running := false
var _health_multiplier := 1.0
var _event_pressure_multiplier := 1.0
var _pressure_spawn_credit := 0.0


func _physics_process(delta: float) -> void:
	if not _running or _enemies_root == null or _target == null or _content_factory == null:
		return
	_run_time += delta
	_apply_time_band(_run_time)
	_spawn_timer = maxf(0.0, _spawn_timer - delta)
	if _spawn_timer <= 0.0:
		_spawn_tick()
		_spawn_timer = _effective_spawn_interval()


## Configures first-playable run spawning.
func configure(enemies_root: Node3D, target: Node3D, content_factory, new_page_half_extents: Vector2) -> void:
	_enemies_root = enemies_root
	_target = target
	_content_factory = content_factory
	page_half_extents = new_page_half_extents
	_apply_time_band(_run_time)


## Starts director time and initial opening spawn.
func start() -> void:
	_running = true
	if _spawned_count == 0 and debug_active_enemy_count() == 0:
		_spawn_tick()
		_spawn_timer = _effective_spawn_interval()


## Stops spawning without clearing existing enemies.
func stop() -> void:
	_running = false


## Resets timeline, counters, and pressure state.
func reset() -> void:
	_spawn_timer = 0.0
	_run_time = 0.0
	_spawned_count = 0
	_spawned_enemy_ids.clear()
	_current_time_band_id = &"opening"
	_health_multiplier = 1.0
	_event_pressure_multiplier = 1.0
	_pressure_spawn_credit = 0.0
	_apply_time_band(_run_time)


## Returns whether the director is running.
func debug_is_running() -> bool:
	return _running


## Returns elapsed run time in seconds for HUD/debug.
func debug_run_time() -> float:
	return _run_time


## Returns total enemies spawned by the director.
func debug_spawned_count() -> int:
	return _spawned_count


## Returns current spawn interval after time-band tuning.
func debug_spawn_interval_seconds() -> float:
	return _effective_spawn_interval()


## Returns current base wave interval before event-pressure overrides.
func debug_base_spawn_interval_seconds() -> float:
	return spawn_interval_seconds


## Returns current director pressure time-band ID.
func debug_current_time_band_id() -> StringName:
	return _current_time_band_id


## Forces elapsed run time for smoke checks and applies pressure band tuning.
func debug_force_run_time(seconds: float) -> void:
	_run_time = maxf(0.0, seconds)
	_apply_time_band(_run_time)
	_spawn_timer = 0.0
	_pressure_spawn_credit = 0.0


## Returns enemy family IDs spawned during this run.
func debug_spawned_enemy_ids() -> Array[StringName]:
	return _spawned_enemy_ids.duplicate()


## Returns current living, targetable enemy count.
func debug_active_enemy_count() -> int:
	return _active_enemies().size()


## Returns pressure target for HUD compatibility; this is not a spawn-stop cap.
func debug_active_budget() -> int:
	return active_budget


## Returns high emergency cap used only for performance safety.
func debug_safety_enemy_cap() -> int:
	return safety_enemy_cap


## Returns current target pressure rate; opening grace can suppress above-minimum pressure.
func debug_spawn_rate_per_second() -> float:
	return _target_kills_per_second()


## Returns target kill-rate curve for smoke/debug checks.
func debug_target_kills_per_second() -> float:
	return _target_kills_per_second()


## Returns target XP/minute implied by kill rate and average XP mix.
func debug_target_xp_per_minute() -> float:
	return _target_kills_per_second() * 60.0 * _average_xp_per_kill()


## Returns current enemy health multiplier.
func debug_health_multiplier() -> float:
	return _health_multiplier


## Returns true when all living enemies are inside finite page bounds.
func debug_all_active_enemies_within_bounds() -> bool:
	for enemy in _active_enemies():
		var position := enemy.global_position
		if absf(position.x) > page_half_extents.x + 0.05:
			return false
		if absf(position.z) > page_half_extents.y + 0.05:
			return false
	return true


## Applies temporary Page Event pressure tuning.
func set_event_pressure_multiplier(multiplier: float) -> void:
	_event_pressure_multiplier = clampf(multiplier, 0.25, 4.0)


func _spawn_tick() -> void:
	var active_count := debug_active_enemy_count()
	if active_count >= safety_enemy_cap:
		return
	var spawn_count := _spawn_count_for_tick(active_count)
	for _index in spawn_count:
		if debug_active_enemy_count() >= safety_enemy_cap:
			return
		_spawn_enemy(_next_enemy_data())


func _spawn_enemy(enemy_data: Resource) -> void:
	if enemy_data == null or debug_active_enemy_count() >= safety_enemy_cap:
		return
	var enemy_body := CharacterBody3D.new()
	_spawned_count += 1
	_spawned_enemy_ids.append(enemy_data.id)
	enemy_body.name = _enemy_node_name(enemy_data, _spawned_count)
	enemy_body.set_script(ChaserEnemyScript)
	_enemies_root.add_child(enemy_body)
	enemy_body.global_position = _spawn_position(_spawned_count)
	if enemy_body.has_method("configure"):
		enemy_body.configure(enemy_data, _target)
	var health := _ensure_health(enemy_body, enemy_data.id, _scaled_enemy_health(enemy_data), &"enemy")
	if enemy_body.has_method("set_health_component"):
		enemy_body.set_health_component(health)


func _active_enemies() -> Array[Node3D]:
	var enemies: Array[Node3D] = []
	if _enemies_root == null:
		return enemies
	for child in _enemies_root.get_children():
		if not child is Node3D or not child.visible:
			continue
		var health := child.get_node_or_null("HealthComponent")
		if health == null or not health.has_method("is_alive") or not health.is_alive():
			continue
		enemies.append(child)
	return enemies


func _ensure_health(owner: Node, entity_id: StringName, max_health: float, team_id: StringName) -> Node:
	var health := owner.get_node_or_null("HealthComponent")
	if health == null:
		health = HealthComponentScript.new()
		health.name = "HealthComponent"
		owner.add_child(health)
	if health.has_method("configure"):
		health.configure(entity_id, max_health, team_id)
	return health


func _next_enemy_data() -> Resource:
	var enemy_pool: Array = []
	if _run_time < 60.0 and _content_factory.has_method("opening_enemy_pool"):
		enemy_pool = _content_factory.opening_enemy_pool()
	elif _content_factory.has_method("pressure_enemy_pool"):
		enemy_pool = _content_factory.pressure_enemy_pool()
	elif _content_factory.has_method("first_playable_enemy_pool"):
		enemy_pool = _content_factory.first_playable_enemy_pool()
	if not enemy_pool.is_empty():
		return enemy_pool[_spawned_count % enemy_pool.size()]
	return _content_factory.wax_imp_enemy()


func _apply_time_band(run_time_seconds: float) -> void:
	var p := _smoothstep(_progress01(run_time_seconds))
	active_budget = _min_alive_for_time(run_time_seconds, p)
	spawn_interval_seconds = lerpf(SPAWN_INTERVAL_START, SPAWN_INTERVAL_END, p)
	spawn_batch_size = maxi(1, floori(_target_kills_per_second() * _effective_spawn_interval()))
	_health_multiplier = lerpf(1.0, HEALTH_MULTIPLIER_END, _progress01(run_time_seconds))
	_current_time_band_id = _band_id_for_minute(run_time_seconds / 60.0)


func _effective_spawn_interval() -> float:
	return maxf(0.1, spawn_interval_seconds / _event_pressure_multiplier)


func _spawn_count_for_tick(active_count: int) -> int:
	var remaining_capacity := maxi(0, safety_enemy_cap - active_count)
	if active_count < active_budget:
		return mini(active_budget - active_count, remaining_capacity)
	if _run_time < OPENING_GRACE_SECONDS:
		_pressure_spawn_credit = 0.0
		return 0
	_pressure_spawn_credit += _target_kills_per_second() * _effective_spawn_interval()
	var pressure_count := floori(_pressure_spawn_credit)
	if pressure_count <= 0:
		return 0
	_pressure_spawn_credit -= float(pressure_count)
	return mini(pressure_count, remaining_capacity)


func _min_alive_for_time(run_time_seconds: float, wave_progress: float) -> int:
	if run_time_seconds < OPENING_GRACE_SECONDS:
		var opening_progress := _smoothstep(clampf(run_time_seconds / OPENING_GRACE_SECONDS, 0.0, 1.0))
		return roundi(lerpf(float(OPENING_MIN_ALIVE_START), float(MIN_ALIVE_START), opening_progress))
	return roundi(lerpf(float(MIN_ALIVE_START), float(MIN_ALIVE_END), wave_progress))


func _progress01(run_time_seconds: float) -> float:
	return clampf((run_time_seconds / 60.0) / TARGET_RUN_MINUTES, 0.0, 1.0)


func _smoothstep(x: float) -> float:
	return x * x * (3.0 - (2.0 * x))


func _target_kills_per_second() -> float:
	var p := _smoothstep(_progress01(_run_time))
	return lerpf(START_KILLS_PER_SECOND, END_KILLS_PER_SECOND, p)


func _average_xp_per_kill() -> float:
	var p := _progress01(_run_time)
	var multiplier := lerpf(AVERAGE_XP_MULTIPLIER_START, AVERAGE_XP_MULTIPLIER_END, p)
	return BASE_ENEMY_XP * multiplier


func _band_id_for_minute(minute: float) -> StringName:
	if minute < 3.0:
		return &"opening"
	if minute < 7.0:
		return &"fast_wave"
	if minute < 12.0:
		return &"tough_wave"
	if minute < 18.0:
		return &"tank_wave"
	if minute < 24.0:
		return &"special_wave"
	return &"elite_wave"


# Enemy durability uses simple visible time-band multipliers for the first slice.
# Opening HP is authored from two starter Waxlight hits; later bands gently multiply
# that base so the player feels early power before pressure rises.
func _scaled_enemy_health(enemy_data: Resource) -> float:
	return maxf(1.0, float(enemy_data.max_health) * _health_multiplier)


func _spawn_position(spawn_number: int) -> Vector3:
	var edge := (spawn_number - 1) % 4
	var offset := (fposmod(float(spawn_number) * 0.47, 1.0) * 2.0) - 1.0
	match edge:
		0:
			return Vector3(page_half_extents.x, 0.0, offset * page_half_extents.y)
		1:
			return Vector3(-page_half_extents.x, 0.0, offset * page_half_extents.y)
		2:
			return Vector3(offset * page_half_extents.x, 0.0, page_half_extents.y)
		_:
			return Vector3(offset * page_half_extents.x, 0.0, -page_half_extents.y)


func _enemy_node_name(enemy_data: Resource, spawn_number: int) -> String:
	if enemy_data.id == &"wax_imp" and spawn_number == 1:
		return "WaxImp"
	return "%s_%d" % [String(enemy_data.id).to_pascal_case(), spawn_number]
