class_name RunUpgradeState
extends RefCounted

const CHOICE_WAXLIGHT_DAMAGE := &"waxlight_damage_plus_1"
const CHOICE_WAXLIGHT_COOLDOWN := &"waxlight_cooldown_minus_10"
const CHOICE_PLAYER_MAX_HP := &"player_max_hp_plus_10"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"

var _waxlight_damage_bonus := 0.0
var _waxlight_cooldown_multiplier := 1.0
var _player_max_health_bonus := 0.0


## Returns the current prototype draft choices with effect IDs.
func prototype_choices() -> Array[Dictionary]:
	return [
		{
			"id": CHOICE_WAXLIGHT_DAMAGE,
			"title": "Waxlight damage +1",
			"description": "Future Waxlight hits and dash activations hit harder.",
		},
		{
			"id": CHOICE_WAXLIGHT_COOLDOWN,
			"title": "Waxlight cooldown -10%",
			"description": "Waxlight Comet fires more often.",
		},
		{
			"id": CHOICE_PLAYER_MAX_HP,
			"title": "Player max HP +10",
			"description": "Increase maximum HP and refill the new amount.",
		},
	]


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
