class_name RunUpgradeState
extends RefCounted

const CHOICE_WAXLIGHT_DAMAGE := &"waxlight_damage_plus_1"
const CHOICE_WAXLIGHT_COOLDOWN := &"waxlight_cooldown_minus_10"
const CHOICE_PLAYER_MAX_HP := &"player_max_hp_plus_10"
const CHOICE_WAXLIGHT_DURATION := &"waxlight_duration_plus_1"
const CHOICE_WAXLIGHT_MARK_CAP := &"waxlight_mark_cap_plus_2"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"

var _waxlight_damage_bonus := 0.0
var _waxlight_cooldown_multiplier := 1.0
var _player_max_health_bonus := 0.0
var _waxlight_active_duration_bonus := 0.0
var _waxlight_unactivated_mark_cap_bonus := 0


## Returns prototype draft choices for one run level.
func prototype_choices_for_level(run_level: int) -> Array[Dictionary]:
	if run_level == 2:
		return [
			_choice(CHOICE_WAXLIGHT_DAMAGE, "Waxlight damage +1", "Waxlight hits and active wax hit harder."),
			_choice(CHOICE_WAXLIGHT_DURATION, "Waxlight duration +1s", "Activated wax stays dangerous longer."),
			_choice(CHOICE_WAXLIGHT_MARK_CAP, "Max unactivated wax +2", "More dormant wax marks can exist at once."),
		]
	if run_level % 3 == 0:
		return [
			_choice(CHOICE_WAXLIGHT_COOLDOWN, "Waxlight cooldown -10%", "Waxlight Comet fires more often."),
			_choice(CHOICE_PLAYER_MAX_HP, "Player max HP +10", "Increase maximum HP and refill the new amount."),
			_choice(CHOICE_WAXLIGHT_DAMAGE, "Waxlight damage +1", "Waxlight hits and active wax hit harder."),
		]
	return [
		_choice(CHOICE_PLAYER_MAX_HP, "Player max HP +10", "Increase maximum HP and refill the new amount."),
		_choice(CHOICE_WAXLIGHT_DURATION, "Waxlight duration +1s", "Activated wax stays dangerous longer."),
		_choice(CHOICE_WAXLIGHT_MARK_CAP, "Max unactivated wax +2", "More dormant wax marks can exist at once."),
	]


## Returns the default prototype draft choices with effect IDs.
func prototype_choices() -> Array[Dictionary]:
	return prototype_choices_for_level(2)


func _choice(choice_id: StringName, title: String, description: String) -> Dictionary:
	return {
		"id": choice_id,
		"title": title,
		"description": description,
	}


## Applies one selected prototype upgrade and returns effect facts.
func apply_choice(choice_id: StringName) -> Dictionary:
	match choice_id:
		CHOICE_WAXLIGHT_DAMAGE:
			_waxlight_damage_bonus += 1.0
			return {
				"choice_id": choice_id,
				"waxlight_damage_bonus": _waxlight_damage_bonus,
			}
		CHOICE_WAXLIGHT_COOLDOWN:
			_waxlight_cooldown_multiplier *= 0.9
			return {
				"choice_id": choice_id,
				"waxlight_cooldown_multiplier": _waxlight_cooldown_multiplier,
			}
		CHOICE_PLAYER_MAX_HP:
			_player_max_health_bonus += 10.0
			return {
				"choice_id": choice_id,
				"player_max_health_delta": 10.0,
				"player_max_health_bonus": _player_max_health_bonus,
			}
		CHOICE_WAXLIGHT_DURATION:
			_waxlight_active_duration_bonus += 1.0
			return {
				"choice_id": choice_id,
				"waxlight_active_duration_bonus": _waxlight_active_duration_bonus,
			}
		CHOICE_WAXLIGHT_MARK_CAP:
			_waxlight_unactivated_mark_cap_bonus += 2
			return {
				"choice_id": choice_id,
				"waxlight_unactivated_mark_cap_bonus": _waxlight_unactivated_mark_cap_bonus,
			}
	return {}


## Returns damage after runtime upgrades for a weapon ID.
func weapon_damage(weapon_id: StringName, base_damage: float) -> float:
	if weapon_id == WEAPON_WAXLIGHT_COMET:
		return base_damage + _waxlight_damage_bonus
	return base_damage


## Returns cooldown after runtime upgrades for a weapon ID.
func weapon_cooldown_seconds(weapon_id: StringName, base_cooldown_seconds: float) -> float:
	if weapon_id == WEAPON_WAXLIGHT_COMET:
		return maxf(0.05, base_cooldown_seconds * _waxlight_cooldown_multiplier)
	return base_cooldown_seconds


## Returns current Waxlight damage bonus.
func waxlight_damage_bonus() -> float:
	return _waxlight_damage_bonus


## Returns current Waxlight cooldown multiplier.
func waxlight_cooldown_multiplier() -> float:
	return _waxlight_cooldown_multiplier


## Returns current player max health bonus.
func player_max_health_bonus() -> float:
	return _player_max_health_bonus


## Returns active Waxlight duration after runtime upgrades.
func waxlight_active_duration_seconds(base_duration_seconds: float) -> float:
	return base_duration_seconds + _waxlight_active_duration_bonus


## Returns unactivated Waxlight cap after runtime upgrades.
func waxlight_unactivated_mark_cap(base_cap: int) -> int:
	return base_cap + _waxlight_unactivated_mark_cap_bonus
