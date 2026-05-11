class_name RunUpgradeState
extends RefCounted

const CHOICE_WAXLIGHT_DAMAGE := &"waxlight_damage_plus_1"
const CHOICE_WAXLIGHT_COOLDOWN := &"waxlight_cooldown_minus_10"
const CHOICE_PLAYER_MAX_HP := &"player_max_hp_plus_10"
const CHOICE_WAXLIGHT_DURATION := &"waxlight_duration_plus_1"
const CHOICE_WAXLIGHT_MARK_CAP := &"waxlight_mark_cap_plus_2"
const CHOICE_NEW_STAR_STICKER := &"new_weapon_star_sticker_swarm"
const CHOICE_STAR_STICKER_LEVEL := &"weapon_upgrade_star_sticker_swarm"
const CHOICE_NEW_CANDLE_SPARK := &"new_passive_candle_spark"
const CHOICE_CANDLE_SPARK_LEVEL := &"passive_upgrade_candle_spark"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const WEAPON_STAR_STICKER_SWARM := &"star_sticker_swarm"
const PASSIVE_CANDLE_SPARK := &"candle_spark"
const MAX_WEAPONS := 5
const MAX_PASSIVES := 5

var _content_factory
var _waxlight_damage_bonus := 0.0
var _waxlight_cooldown_multiplier := 1.0
var _player_max_health_bonus := 0.0
var _waxlight_active_duration_bonus := 0.0
var _waxlight_unactivated_mark_cap_bonus := 0
var _owned_weapon_levels: Dictionary = {}
var _owned_passive_levels: Dictionary = {}


func _init() -> void:
	reset()


## Configures prototype content metadata used by draft choices.
func configure(content_factory) -> void:
	_content_factory = content_factory


## Resets temporary run loadout and stat upgrades.
func reset() -> void:
	_waxlight_damage_bonus = 0.0
	_waxlight_cooldown_multiplier = 1.0
	_player_max_health_bonus = 0.0
	_waxlight_active_duration_bonus = 0.0
	_waxlight_unactivated_mark_cap_bonus = 0
	_owned_weapon_levels = {WEAPON_WAXLIGHT_COMET: 1}
	_owned_passive_levels = {}


## Returns prototype draft choices for one run level.
func prototype_choices_for_level(_run_level: int) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	choices.append(_priority_stat_choice())
	if _can_add_weapon(WEAPON_STAR_STICKER_SWARM):
		choices.append(_new_weapon_choice())
	elif _weapon_level(WEAPON_STAR_STICKER_SWARM) < 10:
		choices.append(_star_sticker_upgrade_choice())
	if _can_add_passive(PASSIVE_CANDLE_SPARK):
		choices.append(_new_passive_choice())
	elif _passive_level(PASSIVE_CANDLE_SPARK) < 5:
		choices.append(_candle_spark_upgrade_choice())
	choices.append(_waxlight_cooldown_choice())
	choices.append(_waxlight_duration_choice())
	choices.append(_waxlight_cap_choice())
	choices.append(_max_hp_choice())
	return _first_unique_choices(choices, 3)


## Returns the default prototype draft choices with effect IDs.
func prototype_choices() -> Array[Dictionary]:
	return prototype_choices_for_level(2)


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
		CHOICE_NEW_STAR_STICKER:
			_owned_weapon_levels[WEAPON_STAR_STICKER_SWARM] = 1
			return {
				"choice_id": choice_id,
				"new_weapon_id": WEAPON_STAR_STICKER_SWARM,
				"weapon_level": 1,
			}
		CHOICE_STAR_STICKER_LEVEL:
			_owned_weapon_levels[WEAPON_STAR_STICKER_SWARM] = mini(10, _weapon_level(WEAPON_STAR_STICKER_SWARM) + 1)
			return {
				"choice_id": choice_id,
				"weapon_id": WEAPON_STAR_STICKER_SWARM,
				"weapon_level": _weapon_level(WEAPON_STAR_STICKER_SWARM),
			}
		CHOICE_NEW_CANDLE_SPARK:
			_owned_passive_levels[PASSIVE_CANDLE_SPARK] = 1
			return {
				"choice_id": choice_id,
				"new_passive_id": PASSIVE_CANDLE_SPARK,
				"passive_level": 1,
				"glow_damage_multiplier": glow_damage_multiplier(),
			}
		CHOICE_CANDLE_SPARK_LEVEL:
			_owned_passive_levels[PASSIVE_CANDLE_SPARK] = mini(5, _passive_level(PASSIVE_CANDLE_SPARK) + 1)
			return {
				"choice_id": choice_id,
				"passive_id": PASSIVE_CANDLE_SPARK,
				"passive_level": _passive_level(PASSIVE_CANDLE_SPARK),
				"glow_damage_multiplier": glow_damage_multiplier(),
			}
	return {}


## Returns damage after runtime upgrades for a weapon ID.
func weapon_damage(weapon_id: StringName, base_damage: float) -> float:
	var damage := base_damage
	if weapon_id == WEAPON_WAXLIGHT_COMET:
		damage += _waxlight_damage_bonus
		damage *= 1.0 + glow_damage_multiplier()
	return damage


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


## Returns passive glow/burn multiplier from Candle Spark.
func glow_damage_multiplier() -> float:
	var level := _passive_level(PASSIVE_CANDLE_SPARK)
	if level <= 0:
		return 0.0
	var passive := _passive_data(PASSIVE_CANDLE_SPARK)
	if passive != null and "level_values" in passive and passive.level_values.size() >= level:
		return float(passive.level_values[level - 1])
	return 0.05 * float(level)


## Returns currently owned weapon IDs.
func owned_weapon_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _owned_weapon_levels.keys():
		ids.append(id)
	return ids


## Returns currently owned passive IDs.
func owned_passive_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _owned_passive_levels.keys():
		ids.append(id)
	return ids


## Returns owned weapon level, or 0 if absent.
func weapon_level(weapon_id: StringName) -> int:
	return _weapon_level(weapon_id)


## Returns owned passive level, or 0 if absent.
func passive_level(passive_id: StringName) -> int:
	return _passive_level(passive_id)


func _waxlight_damage_choice() -> Dictionary:
	var current := _waxlight_damage()
	return _choice(CHOICE_WAXLIGHT_DAMAGE, "Waxlight damage +1", "Damage %.1f -> %.1f" % [current, current + 1.0], "Waxlight hits and active wax hit harder.")


func _priority_stat_choice() -> Dictionary:
	if _waxlight_damage_bonus < 1.0:
		return _waxlight_damage_choice()
	if _waxlight_cooldown_multiplier >= 0.999:
		return _waxlight_cooldown_choice()
	if _player_max_health_bonus < 10.0:
		return _max_hp_choice()
	return _waxlight_damage_choice()


func _waxlight_cooldown_choice() -> Dictionary:
	var current := _waxlight_cooldown()
	var next := current * 0.9
	return _choice(CHOICE_WAXLIGHT_COOLDOWN, "Waxlight cooldown -10%", "Cooldown %.2fs -> %.2fs" % [current, next], "Waxlight Comet fires more often.")


func _waxlight_duration_choice() -> Dictionary:
	var current := waxlight_active_duration_seconds(2.0)
	return _choice(CHOICE_WAXLIGHT_DURATION, "Waxlight duration +1s", "Duration %.1fs -> %.1fs" % [current, current + 1.0], "Activated wax stays dangerous longer.")


func _waxlight_cap_choice() -> Dictionary:
	var current := waxlight_unactivated_mark_cap(6)
	return _choice(CHOICE_WAXLIGHT_MARK_CAP, "Max unactivated wax +2", "Wax cap %d -> %d" % [current, current + 2], "More dormant wax marks can exist at once.")


func _max_hp_choice() -> Dictionary:
	var current := 50.0 + _player_max_health_bonus
	return _choice(CHOICE_PLAYER_MAX_HP, "Player max HP +10", "Max HP %.0f -> %.0f" % [current, current + 10.0], "Increase maximum HP and refill the new amount.")


func _new_weapon_choice() -> Dictionary:
	return _choice(CHOICE_NEW_STAR_STICKER, "Star Sticker Swarm", "Weapon slot %d -> %d" % [_owned_weapon_levels.size(), _owned_weapon_levels.size() + 1], "Gain documented orbit/attach stickers that pop on enemies.")


func _star_sticker_upgrade_choice() -> Dictionary:
	var current := _weapon_level(WEAPON_STAR_STICKER_SWARM)
	return _choice(CHOICE_STAR_STICKER_LEVEL, "Star Sticker Swarm +1", "Level %d -> %d" % [current, current + 1], "Sticker damage and cadence improve.")


func _new_passive_choice() -> Dictionary:
	return _choice(CHOICE_NEW_CANDLE_SPARK, "Candle Spark", "Glow damage +0% -> +5%", "Gain documented Firelight/Waxlight passive.")


func _candle_spark_upgrade_choice() -> Dictionary:
	var current_level := _passive_level(PASSIVE_CANDLE_SPARK)
	var current := glow_damage_multiplier() * 100.0
	var next := _passive_level_value(PASSIVE_CANDLE_SPARK, current_level + 1) * 100.0
	return _choice(CHOICE_CANDLE_SPARK_LEVEL, "Candle Spark +1", "Glow damage +%.0f%% -> +%.0f%%" % [current, next], "Improve glow/burn damage.")


func _choice(choice_id: StringName, title: String, stat_line: String, description: String) -> Dictionary:
	return {
		"id": choice_id,
		"title": title,
		"stat_line": stat_line,
		"description": description,
	}


func _first_unique_choices(source_choices: Array[Dictionary], count: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var seen := {}
	for choice in source_choices:
		var id: StringName = choice.get("id", &"")
		if id == &"" or seen.has(id):
			continue
		seen[id] = true
		result.append(choice)
		if result.size() == count:
			return result
	while result.size() < count:
		var fallback_id := StringName("fallback_heal_%d" % result.size())
		result.append(_choice(fallback_id, "Patch Up", "Heal 0 -> 5", "Fallback heal keeps drafts at three choices."))
	return result


func _can_add_weapon(weapon_id: StringName) -> bool:
	return not _owned_weapon_levels.has(weapon_id) and _owned_weapon_levels.size() < MAX_WEAPONS


func _can_add_passive(passive_id: StringName) -> bool:
	return not _owned_passive_levels.has(passive_id) and _owned_passive_levels.size() < MAX_PASSIVES


func _weapon_level(weapon_id: StringName) -> int:
	return int(_owned_weapon_levels.get(weapon_id, 0))


func _passive_level(passive_id: StringName) -> int:
	return int(_owned_passive_levels.get(passive_id, 0))


func _waxlight_damage() -> float:
	var base := 5.0
	var weapon := _weapon_data(WEAPON_WAXLIGHT_COMET)
	if weapon != null:
		base = float(weapon.level_data_for(1).base_damage)
	return weapon_damage(WEAPON_WAXLIGHT_COMET, base)


func _waxlight_cooldown() -> float:
	var base := 1.15
	var weapon := _weapon_data(WEAPON_WAXLIGHT_COMET)
	if weapon != null:
		base = float(weapon.level_data_for(1).cooldown_seconds)
	return weapon_cooldown_seconds(WEAPON_WAXLIGHT_COMET, base)


func _weapon_data(weapon_id: StringName) -> Resource:
	if _content_factory == null:
		return null
	if weapon_id == WEAPON_WAXLIGHT_COMET and _content_factory.has_method("waxlight_comet_weapon"):
		return _content_factory.waxlight_comet_weapon()
	if weapon_id == WEAPON_STAR_STICKER_SWARM and _content_factory.has_method("star_sticker_swarm_weapon"):
		return _content_factory.star_sticker_swarm_weapon()
	return null


func _passive_data(passive_id: StringName) -> Resource:
	if _content_factory == null:
		return null
	if passive_id == PASSIVE_CANDLE_SPARK and _content_factory.has_method("candle_spark_passive"):
		return _content_factory.candle_spark_passive()
	return null


func _passive_level_value(passive_id: StringName, level: int) -> float:
	var passive := _passive_data(passive_id)
	if passive != null and "level_values" in passive and passive.level_values.size() >= level:
		return float(passive.level_values[level - 1])
	return 0.05 * float(level)
