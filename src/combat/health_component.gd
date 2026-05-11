class_name HealthComponent
extends Node

signal health_changed(previous_health: float, current_health: float)
signal died(entity_id: StringName)

@export var entity_id: StringName
@export var team_id: StringName
@export_range(1.0, 100000.0, 0.1) var max_health := 1.0

var current_health := 1.0
var _death_emitted := false


## Configures one health-bearing entity.
func configure(new_entity_id: StringName, new_max_health: float, new_team_id: StringName) -> void:
	entity_id = new_entity_id
	team_id = new_team_id
	max_health = maxf(1.0, new_max_health)
	current_health = max_health
	_death_emitted = false


## Returns true while this entity can receive normal damage.
func is_alive() -> bool:
	return current_health > 0.0 and not _death_emitted


## Applies resolved damage from DamageModel and returns state-change facts.
func apply_resolved_damage(final_damage: float) -> Dictionary:
	if not is_alive():
		return {
			"applied_damage": 0.0,
			"previous_health": current_health,
			"current_health": current_health,
			"killed": false,
		}

	var previous_health := current_health
	var applied_damage := maxf(0.0, final_damage)
	current_health = clampf(current_health - applied_damage, 0.0, max_health)
	health_changed.emit(previous_health, current_health)

	var killed := previous_health > 0.0 and current_health <= 0.0 and not _death_emitted
	if killed:
		_death_emitted = true
		died.emit(entity_id)

	return {
		"applied_damage": applied_damage,
		"previous_health": previous_health,
		"current_health": current_health,
		"killed": killed,
	}


## Restores health for spawn/reuse flows.
func reset_health(new_max_health: float = -1.0) -> void:
	if new_max_health > 0.0:
		max_health = new_max_health
	current_health = max_health
	_death_emitted = false


## Increases max health and optionally heals by the added amount.
func add_max_health(delta: float, heal_added_amount: bool = true) -> Dictionary:
	var previous_max_health := max_health
	var previous_health := current_health
	max_health = maxf(1.0, max_health + delta)
	if heal_added_amount:
		current_health = clampf(current_health + delta, 0.0, max_health)
	else:
		current_health = clampf(current_health, 0.0, max_health)
	health_changed.emit(previous_health, current_health)
	return {
		"previous_max_health": previous_max_health,
		"max_health": max_health,
		"previous_health": previous_health,
		"current_health": current_health,
	}
