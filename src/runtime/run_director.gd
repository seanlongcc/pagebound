class_name RunDirector
extends Node

const ChaserEnemyScript := preload("res://src/enemies/chaser_enemy.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")
const TIME_BANDS := [
	{"id": &"opening", "start_seconds": 0.0, "budget": 4, "spawn_interval": 0.9},
	{"id": &"first_pressure", "start_seconds": 60.0, "budget": 6, "spawn_interval": 0.75},
	{"id": &"ink_surge", "start_seconds": 120.0, "budget": 8, "spawn_interval": 0.6},
	{"id": &"page_crush", "start_seconds": 240.0, "budget": 10, "spawn_interval": 0.5},
]

@export_range(1, 128, 1) var active_budget := 4
@export_range(0.1, 60.0, 0.05) var spawn_interval_seconds := 0.9
@export var page_half_extents := Vector2(7.7, 4.7)

var _enemies_root: Node3D
var _target: Node3D
var _content_factory
var _spawn_timer := 0.0
var _run_time := 0.0
var _spawned_count := 0
var _current_time_band_id: StringName = &"opening"
var _spawned_enemy_ids: Array[StringName] = []


func _physics_process(delta: float) -> void:
	if _enemies_root == null or _target == null or _content_factory == null:
		return
	_run_time += delta
	_apply_time_band(_run_time)
	_spawn_timer = maxf(0.0, _spawn_timer - delta)
	if _spawn_timer <= 0.0 and debug_active_enemy_count() < active_budget:
		_spawn_enemy(_next_enemy_data())
		_spawn_timer = spawn_interval_seconds


## Configures first-playable run spawning.
func configure(enemies_root: Node3D, target: Node3D, content_factory, new_page_half_extents: Vector2) -> void:
	_enemies_root = enemies_root
	_target = target
	_content_factory = content_factory
	page_half_extents = new_page_half_extents
	_apply_time_band(_run_time)
	if _spawned_count == 0 and debug_active_enemy_count() == 0:
		_spawn_enemy(_next_enemy_data())
		_spawn_timer = spawn_interval_seconds


## Returns elapsed run time in seconds for HUD/debug.
func debug_run_time() -> float:
	return _run_time


## Returns total enemies spawned by the director.
func debug_spawned_count() -> int:
	return _spawned_count


## Returns current spawn interval after time-band tuning.
func debug_spawn_interval_seconds() -> float:
	return spawn_interval_seconds


## Returns current director pressure time-band ID.
func debug_current_time_band_id() -> StringName:
	return _current_time_band_id


## Forces elapsed run time for smoke checks and applies pressure band tuning.
func debug_force_run_time(seconds: float) -> void:
	_run_time = maxf(0.0, seconds)
	_apply_time_band(_run_time)
	_spawn_timer = minf(_spawn_timer, spawn_interval_seconds)


## Returns enemy family IDs spawned during this run.
func debug_spawned_enemy_ids() -> Array[StringName]:
	return _spawned_enemy_ids.duplicate()


## Returns current living, targetable enemy count.
func debug_active_enemy_count() -> int:
	return _active_enemies().size()


## Returns active enemy budget.
func debug_active_budget() -> int:
	return active_budget


## Returns true when all living enemies are inside finite page bounds.
func debug_all_active_enemies_within_bounds() -> bool:
	for enemy in _active_enemies():
		var position := enemy.global_position
		if absf(position.x) > page_half_extents.x + 0.05:
			return false
		if absf(position.z) > page_half_extents.y + 0.05:
			return false
	return true


func _spawn_enemy(enemy_data: Resource) -> void:
	if enemy_data == null or debug_active_enemy_count() >= active_budget:
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
	var health := _ensure_health(enemy_body, enemy_data.id, enemy_data.max_health, &"enemy")
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
	if _content_factory.has_method("first_playable_enemy_pool"):
		var enemy_pool: Array = _content_factory.first_playable_enemy_pool()
		if not enemy_pool.is_empty():
			return enemy_pool[_spawned_count % enemy_pool.size()]
	return _content_factory.inkling_chaser_enemy()


func _apply_time_band(run_time_seconds: float) -> void:
	var selected_band := TIME_BANDS[0]
	for band in TIME_BANDS:
		if run_time_seconds >= float(band["start_seconds"]):
			selected_band = band
	active_budget = int(selected_band["budget"])
	spawn_interval_seconds = float(selected_band["spawn_interval"])
	_current_time_band_id = selected_band["id"]


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
	if enemy_data.id == &"inkling_chaser" and spawn_number == 1:
		return "InklingChaser"
	return "%s_%d" % [String(enemy_data.id).to_pascal_case(), spawn_number]
