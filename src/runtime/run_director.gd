class_name RunDirector
extends Node

const ChaserEnemyScript := preload("res://src/enemies/chaser_enemy.gd")
const EnemyPoolScript := preload("res://src/enemies/enemy_pool.gd")
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
const HEALTH_MULTIPLIER_END := 8.0
const HEALTH_SCALING_CURVE := 1.6

@export_range(1, 1000, 1) var safety_enemy_cap := 350
@export_range(1, 512, 1) var active_budget := OPENING_MIN_ALIVE_START
@export_range(0.1, 60.0, 0.05) var spawn_interval_seconds := SPAWN_INTERVAL_START
@export_range(1, 16, 1) var spawn_batch_size := 1
@export var page_half_extents := Vector2(11.0, 7.0)

var _enemies_root: Node3D
var _target: Node3D
var _content_factory
var _enemy_pool: Node
var _active_enemy_registry: Node
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
	_active_enemy_registry = _active_enemy_registry_from_root()
	_ensure_enemy_pool()
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
	if _active_enemy_registry != null and _active_enemy_registry.has_method("clear"):
		_active_enemy_registry.clear()
	if _enemy_pool != null and _enemy_pool.has_method("clear"):
		_enemy_pool.clear()
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
	if _active_enemy_registry != null and _active_enemy_registry.has_method("active_count"):
		return _active_enemy_registry.active_count()
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


## Returns one director-owned enemy to the pool after death.
func return_enemy(enemy: Node) -> bool:
	if enemy == null or _enemy_pool == null or not _enemy_pool.has_method("owns_instance"):
		return false
	if not _enemy_pool.owns_instance(enemy):
		return false
	if _active_enemy_registry != null and _active_enemy_registry.has_method("unregister_enemy"):
		_active_enemy_registry.unregister_enemy(enemy)
	_enemy_pool.return_instance(enemy)
	return true


## Returns enemy pool counters for smoke/debug checks.
func debug_enemy_pool_stats() -> Dictionary:
	if _enemy_pool == null:
		return {}
	return {
		"active": _enemy_pool.debug_active_count() if _enemy_pool.has_method("debug_active_count") else 0,
		"inactive": _enemy_pool.debug_inactive_count() if _enemy_pool.has_method("debug_inactive_count") else 0,
		"total": _enemy_pool.debug_total_count() if _enemy_pool.has_method("debug_total_count") else 0,
		"spawned": _enemy_pool.debug_spawned_count() if _enemy_pool.has_method("debug_spawned_count") else 0,
		"reused": _enemy_pool.debug_reused_count() if _enemy_pool.has_method("debug_reused_count") else 0,
		"returned": _enemy_pool.debug_returned_count() if _enemy_pool.has_method("debug_returned_count") else 0,
		"dropped": _enemy_pool.debug_dropped_count() if _enemy_pool.has_method("debug_dropped_count") else 0,
	}


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
	var enemy_body := _request_enemy_body()
	if enemy_body == null:
		return
	_spawned_count += 1
	_spawned_enemy_ids.append(enemy_data.id)
	enemy_body.name = _enemy_node_name(enemy_data, _spawned_count)
	enemy_body.global_position = _spawn_position(_spawned_count)
	if enemy_body.has_method("configure"):
		enemy_body.configure(enemy_data, _target)
	var health := _ensure_health(enemy_body, enemy_data.id, _scaled_enemy_health(enemy_data), &"enemy")
	if enemy_body.has_method("set_health_component"):
		enemy_body.set_health_component(health)
	_activate_enemy_body(enemy_body)
	if _active_enemy_registry != null and _active_enemy_registry.has_method("register_enemy"):
		_active_enemy_registry.register_enemy(enemy_body)


func _active_enemies() -> Array[Node3D]:
	if _active_enemy_registry != null and _active_enemy_registry.has_method("active_enemies"):
		return _active_enemy_registry.active_enemies()
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


func _ensure_enemy_pool() -> void:
	if _enemies_root == null:
		return
	if _enemy_pool == null:
		_enemy_pool = get_node_or_null("EnemyPool")
	if _enemy_pool == null:
		_enemy_pool = EnemyPoolScript.new()
		_enemy_pool.name = "EnemyPool"
		add_child(_enemy_pool)
	if _enemy_pool.has_method("configure"):
		_enemy_pool.configure(_enemies_root, Callable(self, "_create_enemy_body"), safety_enemy_cap, 0)


func _request_enemy_body() -> CharacterBody3D:
	_ensure_enemy_pool()
	if _enemy_pool == null or not _enemy_pool.has_method("request_instance"):
		return null
	return _enemy_pool.request_instance() as CharacterBody3D


func _create_enemy_body() -> Node:
	var enemy_body := CharacterBody3D.new()
	enemy_body.set_script(ChaserEnemyScript)
	return enemy_body


func _activate_enemy_body(enemy_body: Node) -> void:
	if enemy_body == null:
		return
	if enemy_body.has_method("activate_from_pool"):
		enemy_body.activate_from_pool()
	else:
		enemy_body.visible = true
		enemy_body.set_physics_process(true)
	var collision := enemy_body.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if collision != null:
		collision.disabled = false


func _active_enemy_registry_from_root() -> Node:
	if _enemies_root == null:
		return null
	var current: Node = _enemies_root
	while current != null and current.name != "RunRoot":
		current = current.get_parent()
	if current == null:
		return null
	return current.get_node_or_null("ActiveEnemyRegistry")


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
	_health_multiplier = _enemy_health_multiplier(run_time_seconds)
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


func _enemy_health_multiplier(run_time_seconds: float) -> float:
	var p := _progress01(run_time_seconds)
	return 1.0 + ((HEALTH_MULTIPLIER_END - 1.0) * pow(p, HEALTH_SCALING_CURVE))


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


# Enemy durability uses an eased 1x -> 8x curve over the 30-minute run.
# Opening HP is authored against the Star Sticker Swarm starter baseline.
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
