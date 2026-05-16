class_name CrownlessEchoController
extends RefCounted

const ChaserEnemyScript := preload("res://src/enemies/chaser_enemy.gd")
const EnemyDataScript := preload("res://src/data/enemy_data.gd")
const HealthComponentScript := preload("res://src/combat/health_component.gd")

const BOSS_ID := &"crownless_echo"
const BOSS_DISPLAY_NAME := "Crownless Echo"
const BOSS_BANNER_TITLE := "The Scribble King Stirs"
const SPAWN_TIME_SECONDS := 210.0
const MAX_HEALTH := 2400.0
const CONTACT_DAMAGE := 240.0
const REWARD_XP := 1000

var _enemies_root: Node3D
var _target: Node3D
var _damage_model
var _page_half_extents := Vector2(32.0, 20.0)
var _boss: Node3D
var _queued_for_event := false
var _defeated := false


func configure(enemies_root: Node3D, target: Node3D, damage_model, page_half_extents: Vector2) -> void:
	_enemies_root = enemies_root
	_target = target
	_damage_model = damage_model
	_page_half_extents = page_half_extents


func reset() -> void:
	_boss = null
	_queued_for_event = false
	_defeated = false


func tick(run_time_seconds: float, page_event_active: bool) -> void:
	_sync_defeat()
	if _defeated:
		return
	if _boss != null:
		return
	if run_time_seconds < SPAWN_TIME_SECONDS:
		return
	if page_event_active:
		_queued_for_event = true
		return
	_spawn_boss()


func damage_boss(amount: float) -> void:
	if _boss == null or _damage_model == null:
		return
	var health := _boss.get_node_or_null("HealthComponent")
	if health != null:
		_damage_model.apply_damage(health, BOSS_ID, amount, [&"blankness", &"boss"])
	_sync_defeat()


func state() -> Dictionary:
	_sync_defeat()
	var health := _health()
	var current := 0.0
	var max_value := MAX_HEALTH
	if health != null:
		current = float(health.current_health)
		max_value = float(health.max_health)
	return {
		"id": BOSS_ID if _boss != null or _queued_for_event or _defeated else &"",
		"display_name": BOSS_DISPLAY_NAME,
		"title": BOSS_BANNER_TITLE,
		"active": _boss != null and not _defeated,
		"queued_for_event": _queued_for_event,
		"defeated": _defeated,
		"current_health": current,
		"max_health": max_value,
		"contact_damage": CONTACT_DAMAGE,
		"hp_percent": ceili(clampf(current / maxf(1.0, max_value), 0.0, 1.0) * 100.0),
		"spawn_time_seconds": SPAWN_TIME_SECONDS,
	}


func _spawn_boss() -> void:
	if _enemies_root == null or _target == null:
		return
	_queued_for_event = false
	var boss_body := CharacterBody3D.new()
	boss_body.name = "CrownlessEcho"
	boss_body.set_script(ChaserEnemyScript)
	_enemies_root.add_child(boss_body)
	boss_body.global_position = _spawn_position()
	if boss_body.has_method("configure"):
		boss_body.configure(_boss_data(), _target)
	var health := _ensure_health(boss_body, BOSS_ID, MAX_HEALTH, &"enemy")
	if boss_body.has_method("set_health_component"):
		boss_body.set_health_component(health)
	_boss = boss_body


func _spawn_position() -> Vector3:
	var center := Vector3.ZERO
	if _target != null:
		center = _target.global_position
	var x := clampf(center.x + 10.0, -_page_half_extents.x + 1.5, _page_half_extents.x - 1.5)
	var z := clampf(center.z, -_page_half_extents.y + 1.5, _page_half_extents.y - 1.5)
	return Vector3(x, 0.0, z)


func _boss_data() -> Resource:
	var enemy = EnemyDataScript.new()
	enemy.id = BOSS_ID
	enemy.display_name = BOSS_DISPLAY_NAME
	enemy.description = "Killable first polished exemplar mini-boss echo."
	enemy.tags = _string_name_array([&"blankness", &"prototype"])
	enemy.behavior_id = &"boss_chaser"
	enemy.max_health = MAX_HEALTH
	enemy.move_speed = 1.65
	enemy.contact_damage = CONTACT_DAMAGE
	enemy.reward_xp = REWARD_XP
	enemy.pagecraft_interaction_tags = _string_name_array([&"waxlight"])
	return enemy


func _ensure_health(owner: Node, entity_id: StringName, max_health: float, team_id: StringName) -> Node:
	var health := owner.get_node_or_null("HealthComponent")
	if health == null:
		health = HealthComponentScript.new()
		health.name = "HealthComponent"
		owner.add_child(health)
	if health.has_method("configure"):
		health.configure(entity_id, max_health, team_id)
	return health


func _health() -> Node:
	if _boss == null:
		return null
	return _boss.get_node_or_null("HealthComponent")


func _sync_defeat() -> void:
	if _boss == null:
		return
	var health := _health()
	if health != null and health.has_method("is_alive") and not health.is_alive():
		_defeated = true
		_boss = null


func _string_name_array(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		result.append(value)
	return result
