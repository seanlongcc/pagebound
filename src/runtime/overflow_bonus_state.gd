class_name OverflowBonusState
extends RefCounted

const BONUS_VALUE := 0.05
const CHOICE_STATS := {
	&"overflow_damage_crumb": &"damage",
	&"overflow_range_crumb": &"range",
	&"overflow_size_crumb": &"size",
	&"overflow_cadence_crumb": &"cadence",
	&"overflow_duration_crumb": &"duration",
}

var _stat_bonuses: Dictionary = {}


func reset() -> void:
	_stat_bonuses = {}


func apply_choice(choice_id: StringName) -> Dictionary:
	if not CHOICE_STATS.has(choice_id):
		return {}
	var stat: StringName = CHOICE_STATS[choice_id]
	_stat_bonuses[stat] = bonus(stat) + BONUS_VALUE
	return {
		"choice_id": choice_id,
		"choice_type": &"overflow",
		"stat_id": stat,
		"value": BONUS_VALUE,
		"total_bonus": bonus(stat),
	}


func bonus(stat: StringName) -> float:
	return float(_stat_bonuses.get(stat, 0.0))
