class_name RunUpgradeState
extends RefCounted

const CHOICE_WAXLIGHT_DAMAGE := &"waxlight_damage_plus_1"
const CHOICE_WAXLIGHT_DAMAGE_RARE := &"waxlight_damage_plus_4"
const CHOICE_WAXLIGHT_COOLDOWN := &"waxlight_cooldown_minus_10"
const CHOICE_PLAYER_MAX_HP := &"player_max_hp_plus_10"
const CHOICE_PLAYER_MAX_HP_LEGENDARY := &"player_max_hp_plus_40"
const CHOICE_WAXLIGHT_DURATION := &"waxlight_duration_plus_1"
const CHOICE_WAXLIGHT_DURATION_EPIC := &"waxlight_duration_plus_2"
const CHOICE_WAXLIGHT_MARK_CAP := &"waxlight_mark_cap_plus_2"
const CHOICE_NEW_STAR_STICKER := &"new_weapon_star_sticker_swarm"
const CHOICE_NEW_PAPER_PLANE := &"new_weapon_paper_plane_dart"
const CHOICE_NEW_MARGIN_SPARK := &"new_weapon_margin_spark_ring"
const CHOICE_STAR_STICKER_DAMAGE := &"weapon_upgrade_star_sticker_damage"
const CHOICE_STAR_STICKER_COUNT := &"weapon_upgrade_star_sticker_count"
const CHOICE_NEW_CANDLE_SPARK := &"new_passive_candle_spark"
const CHOICE_CANDLE_SPARK_LEVEL := &"passive_upgrade_candle_spark"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const WEAPON_STAR_STICKER_SWARM := &"star_sticker_swarm"
const WEAPON_PAPER_PLANE_DART := &"paper_plane_dart"
const WEAPON_MARGIN_SPARK_RING := &"margin_spark_ring"
const PASSIVE_CANDLE_SPARK := &"candle_spark"
const MAX_WEAPONS := 5
const MAX_PASSIVES := 5
const DRAFT_CHOICE_COUNT := 3
const WAXLIGHT_DAMAGE_STEP := 2.0
const WAXLIGHT_DAMAGE_RARE_STEP := 4.0
const WAXLIGHT_COOLDOWN_REDUCTION_STEP := 0.25
const PLAYER_MAX_HEALTH_STEP := 20.0
const PLAYER_MAX_HEALTH_LEGENDARY_STEP := 40.0
const WAXLIGHT_MARK_CAP_STEP := 3
const CANDLE_SPARK_FALLBACK_STEP := 0.15
const STAR_STICKER_DAMAGE_STEP := 2.0
const STAR_STICKER_COUNT_STEP := 1
const MAX_STAR_STICKER_COUNT := 4
const RARITY_COMMON := &"common"
const RARITY_UNCOMMON := &"uncommon"
const RARITY_RARE := &"rare"
const RARITY_EPIC := &"epic"
const RARITY_LEGENDARY := &"legendary"
const RARITY_ORDER := [RARITY_COMMON, RARITY_UNCOMMON, RARITY_RARE, RARITY_EPIC, RARITY_LEGENDARY]
const RARITY_WEIGHTS := {
	RARITY_COMMON: 60.0,
	RARITY_UNCOMMON: 25.0,
	RARITY_RARE: 9.0,
	RARITY_EPIC: 5.0,
	RARITY_LEGENDARY: 1.0,
}
const CATEGORY_WEIGHTS := {
	&"weapon_upgrade": 1.15,
	&"passive": 1.05,
	&"passive_upgrade": 1.0,
	&"stat": 1.0,
	&"fallback": 0.2,
}
const WEAPON_PICK_LEVELS := [2, 6, 10, 14]

var _content_factory
var _waxlight_damage_bonus := 0.0
var _waxlight_cooldown_reduction_seconds := 0.0
var _player_max_health_bonus := 0.0
var _waxlight_active_duration_bonus := 0.0
var _waxlight_unactivated_mark_cap_bonus := 0
var _star_sticker_damage_bonus := 0.0
var _star_sticker_count_bonus := 0
var _owned_weapon_levels: Dictionary = {}
var _owned_passive_levels: Dictionary = {}
var _draft_seed := 1337


func _init() -> void:
	reset()


## Configures prototype content metadata used by draft choices.
func configure(content_factory) -> void:
	_content_factory = content_factory


## Resets temporary run loadout and stat upgrades.
func reset() -> void:
	_waxlight_damage_bonus = 0.0
	_waxlight_cooldown_reduction_seconds = 0.0
	_player_max_health_bonus = 0.0
	_waxlight_active_duration_bonus = 0.0
	_waxlight_unactivated_mark_cap_bonus = 0
	_star_sticker_damage_bonus = 0.0
	_star_sticker_count_bonus = 0
	_owned_weapon_levels = {WEAPON_WAXLIGHT_COMET: 1}
	_owned_passive_levels = {}


## Returns prototype draft choices for one run level.
func prototype_choices_for_level(run_level: int) -> Array[Dictionary]:
	if _is_weapon_pick_level(run_level):
		return _weapon_pick_choices()
	return _weighted_unique_choices(debug_eligible_choices_for_level(run_level), DRAFT_CHOICE_COUNT, _draft_seed_for_level(run_level))


## Returns the default prototype draft choices with effect IDs.
func prototype_choices() -> Array[Dictionary]:
	return prototype_choices_for_level(2)


## Applies one selected prototype upgrade and returns effect facts.
func apply_choice(choice_id: StringName) -> Dictionary:
	match choice_id:
		CHOICE_WAXLIGHT_DAMAGE:
			_waxlight_damage_bonus += WAXLIGHT_DAMAGE_STEP
			return _stat_event(choice_id)
		CHOICE_WAXLIGHT_DAMAGE_RARE:
			_waxlight_damage_bonus += WAXLIGHT_DAMAGE_RARE_STEP
			return _stat_event(choice_id)
		CHOICE_WAXLIGHT_COOLDOWN:
			_waxlight_cooldown_reduction_seconds += WAXLIGHT_COOLDOWN_REDUCTION_STEP
			return _stat_event(choice_id)
		CHOICE_PLAYER_MAX_HP:
			_player_max_health_bonus += PLAYER_MAX_HEALTH_STEP
			return _health_event(choice_id, PLAYER_MAX_HEALTH_STEP)
		CHOICE_PLAYER_MAX_HP_LEGENDARY:
			_player_max_health_bonus += PLAYER_MAX_HEALTH_LEGENDARY_STEP
			return _health_event(choice_id, PLAYER_MAX_HEALTH_LEGENDARY_STEP)
		CHOICE_WAXLIGHT_DURATION:
			_waxlight_active_duration_bonus += 1.0
			return _stat_event(choice_id)
		CHOICE_WAXLIGHT_DURATION_EPIC:
			_waxlight_active_duration_bonus += 2.0
			return _stat_event(choice_id)
		CHOICE_WAXLIGHT_MARK_CAP:
			_waxlight_unactivated_mark_cap_bonus += WAXLIGHT_MARK_CAP_STEP
			return _stat_event(choice_id)
		CHOICE_NEW_STAR_STICKER:
			return _add_weapon(choice_id, WEAPON_STAR_STICKER_SWARM)
		CHOICE_NEW_PAPER_PLANE:
			return _add_weapon(choice_id, WEAPON_PAPER_PLANE_DART)
		CHOICE_NEW_MARGIN_SPARK:
			return _add_weapon(choice_id, WEAPON_MARGIN_SPARK_RING)
		CHOICE_STAR_STICKER_DAMAGE:
			if not _owned_weapon_levels.has(WEAPON_STAR_STICKER_SWARM):
				return {}
			_star_sticker_damage_bonus += STAR_STICKER_DAMAGE_STEP
			return {
				"choice_id": choice_id,
				"weapon_id": WEAPON_STAR_STICKER_SWARM,
				"star_sticker_damage_bonus": _star_sticker_damage_bonus,
			}
		CHOICE_STAR_STICKER_COUNT:
			if not _owned_weapon_levels.has(WEAPON_STAR_STICKER_SWARM):
				return {}
			_star_sticker_count_bonus = mini(MAX_STAR_STICKER_COUNT - 1, _star_sticker_count_bonus + STAR_STICKER_COUNT_STEP)
			return {
				"choice_id": choice_id,
				"weapon_id": WEAPON_STAR_STICKER_SWARM,
				"star_sticker_count_bonus": _star_sticker_count_bonus,
			}
		CHOICE_NEW_CANDLE_SPARK:
			_owned_passive_levels[PASSIVE_CANDLE_SPARK] = 1
			return _passive_event(choice_id, true)
		CHOICE_CANDLE_SPARK_LEVEL:
			_owned_passive_levels[PASSIVE_CANDLE_SPARK] = mini(5, _passive_level(PASSIVE_CANDLE_SPARK) + 1)
			return _passive_event(choice_id, false)
	return {}


## Returns damage after runtime upgrades for a weapon ID.
func weapon_damage(weapon_id: StringName, base_damage: float) -> float:
	var damage := base_damage
	if weapon_id == WEAPON_WAXLIGHT_COMET:
		damage += _waxlight_damage_bonus
	elif weapon_id == WEAPON_STAR_STICKER_SWARM:
		damage += _star_sticker_damage_bonus
	return damage_for_tags(weapon_id, damage, _weapon_material_tags(weapon_id))


## Returns damage after tag-family passive modifiers.
func damage_for_tags(_source_id: StringName, base_damage: float, damage_tags: Array) -> float:
	if _tags_match_candle_spark(damage_tags):
		return base_damage * (1.0 + glow_damage_multiplier())
	return base_damage


## Returns projectile/count modifier for weapons that expose one.
func weapon_projectile_count(weapon_id: StringName, base_count: int) -> int:
	if weapon_id == WEAPON_STAR_STICKER_SWARM:
		return clampi(base_count + _star_sticker_count_bonus, 1, MAX_STAR_STICKER_COUNT)
	return base_count


## Returns cooldown after runtime upgrades for a weapon ID.
func weapon_cooldown_seconds(weapon_id: StringName, base_cooldown_seconds: float) -> float:
	if weapon_id == WEAPON_WAXLIGHT_COMET:
		return maxf(0.25, base_cooldown_seconds - _waxlight_cooldown_reduction_seconds)
	return base_cooldown_seconds


## Returns current Waxlight damage bonus.
func waxlight_damage_bonus() -> float:
	return _waxlight_damage_bonus


## Returns current Waxlight cooldown multiplier.
func waxlight_cooldown_multiplier() -> float:
	var base_cooldown := _waxlight_base_cooldown()
	if base_cooldown <= 0.0:
		return 1.0
	return weapon_cooldown_seconds(WEAPON_WAXLIGHT_COMET, base_cooldown) / base_cooldown


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
	return CANDLE_SPARK_FALLBACK_STEP * float(level)


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


## Sets deterministic draft seed for smoke checks.
func debug_set_draft_seed(seed: int) -> void:
	_draft_seed = seed


## Returns current draft rarity weights for smoke checks.
func debug_rarity_weights() -> Dictionary:
	return RARITY_WEIGHTS.duplicate(true)


## Returns currently eligible non-interval draft choices for smoke checks.
func debug_eligible_choices_for_level(_run_level: int) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	if _owned_weapon_levels.has(WEAPON_STAR_STICKER_SWARM):
		choices.append(_star_sticker_damage_choice())
		if weapon_projectile_count(WEAPON_STAR_STICKER_SWARM, 1) < MAX_STAR_STICKER_COUNT:
			choices.append(_star_sticker_count_choice())
	if _can_add_passive(PASSIVE_CANDLE_SPARK):
		choices.append(_new_passive_choice())
	elif _passive_level(PASSIVE_CANDLE_SPARK) < 5:
		choices.append(_candle_spark_upgrade_choice())
	choices.append(_waxlight_damage_choice())
	choices.append(_waxlight_damage_rare_choice())
	choices.append(_waxlight_cooldown_choice())
	choices.append(_waxlight_duration_choice())
	choices.append(_waxlight_duration_epic_choice())
	choices.append(_waxlight_cap_choice())
	choices.append(_max_hp_choice())
	choices.append(_max_hp_legendary_choice())
	return choices


func _weapon_pick_choices() -> Array[Dictionary]:
	var choices := _new_weapon_choices()
	if choices.size() >= DRAFT_CHOICE_COUNT:
		return _first_unique_choices(choices, DRAFT_CHOICE_COUNT)
	var filled := _first_unique_choices(choices + _weighted_unique_choices(debug_eligible_choices_for_level(0), DRAFT_CHOICE_COUNT, _draft_seed_for_level(0)), DRAFT_CHOICE_COUNT)
	return filled


func _new_weapon_choices() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	if _can_add_weapon(WEAPON_STAR_STICKER_SWARM):
		choices.append(_new_weapon_choice(
			CHOICE_NEW_STAR_STICKER,
			WEAPON_STAR_STICKER_SWARM,
			RARITY_RARE,
			"Gain orbiting stickers that fire, stick to the page, pop, and reform."
		))
	if _can_add_weapon(WEAPON_PAPER_PLANE_DART):
		choices.append(_new_weapon_choice(
			CHOICE_NEW_PAPER_PLANE,
			WEAPON_PAPER_PLANE_DART,
			RARITY_UNCOMMON,
			"Launch a fast folded dart line through the nearest target."
		))
	if _can_add_weapon(WEAPON_MARGIN_SPARK_RING):
		choices.append(_new_weapon_choice(
			CHOICE_NEW_MARGIN_SPARK,
			WEAPON_MARGIN_SPARK_RING,
			RARITY_RARE,
			"Pop a primitive margin ring that hits enemies grouped around a target."
		))
	return choices


func _new_weapon_choice(choice_id: StringName, weapon_id: StringName, rarity: StringName, description: String) -> Dictionary:
	return _choice(
		choice_id,
		_weapon_display_name(weapon_id),
		"Weapon slot %d -> %d" % [_owned_weapon_levels.size(), _owned_weapon_levels.size() + 1],
		description,
		&"weapon",
		rarity,
		weapon_id,
		&"",
		&"",
		1.0,
		1.0
	)


func _waxlight_damage_choice() -> Dictionary:
	var current := _waxlight_damage()
	return _choice(CHOICE_WAXLIGHT_DAMAGE, "Waxlight damage +2", "Damage %.1f -> %.1f" % [current, current + WAXLIGHT_DAMAGE_STEP], "Waxlight and Firelight-tagged hits hit harder.", &"stat", RARITY_COMMON, WEAPON_WAXLIGHT_COMET, &"", &"waxlight_damage", WAXLIGHT_DAMAGE_STEP, 1.0)


func _waxlight_damage_rare_choice() -> Dictionary:
	var current := _waxlight_damage()
	return _choice(CHOICE_WAXLIGHT_DAMAGE_RARE, "Waxlight damage +4", "Damage %.1f -> %.1f" % [current, current + WAXLIGHT_DAMAGE_RARE_STEP], "Rare Waxlight/Firelight damage boost.", &"stat", RARITY_RARE, WEAPON_WAXLIGHT_COMET, &"", &"waxlight_damage", WAXLIGHT_DAMAGE_RARE_STEP, 0.8)


func _waxlight_cooldown_choice() -> Dictionary:
	var current := _waxlight_cooldown()
	var next := maxf(0.25, current - WAXLIGHT_COOLDOWN_REDUCTION_STEP)
	return _choice(CHOICE_WAXLIGHT_COOLDOWN, "Waxlight cooldown -0.25s", "Cooldown %.2fs -> %.2fs" % [current, next], "Waxlight Comet fires more often.", &"stat", RARITY_UNCOMMON, WEAPON_WAXLIGHT_COMET, &"", &"waxlight_cooldown", -WAXLIGHT_COOLDOWN_REDUCTION_STEP, 1.0)


func _waxlight_duration_choice() -> Dictionary:
	var current := waxlight_active_duration_seconds(2.0)
	return _choice(CHOICE_WAXLIGHT_DURATION, "Waxlight duration +1s", "Duration %.1fs -> %.1fs" % [current, current + 1.0], "Activated wax stays dangerous longer.", &"stat", RARITY_UNCOMMON, WEAPON_WAXLIGHT_COMET, &"", &"waxlight_duration", 1.0, 1.0)


func _waxlight_duration_epic_choice() -> Dictionary:
	var current := waxlight_active_duration_seconds(2.0)
	return _choice(CHOICE_WAXLIGHT_DURATION_EPIC, "Waxlight duration +2s", "Duration %.1fs -> %.1fs" % [current, current + 2.0], "Epic Waxlight duration boost.", &"stat", RARITY_EPIC, WEAPON_WAXLIGHT_COMET, &"", &"waxlight_duration", 2.0, 0.6)


func _waxlight_cap_choice() -> Dictionary:
	var current := waxlight_unactivated_mark_cap(6)
	return _choice(CHOICE_WAXLIGHT_MARK_CAP, "Max unactivated wax +3", "Wax cap %d -> %d" % [current, current + WAXLIGHT_MARK_CAP_STEP], "More dormant wax marks can exist at once.", &"stat", RARITY_COMMON, WEAPON_WAXLIGHT_COMET, &"", &"waxlight_mark_cap", WAXLIGHT_MARK_CAP_STEP, 1.0)


func _max_hp_choice() -> Dictionary:
	var current := 50.0 + _player_max_health_bonus
	return _choice(CHOICE_PLAYER_MAX_HP, "Player max HP +20", "Max HP %.0f -> %.0f" % [current, current + PLAYER_MAX_HEALTH_STEP], "Increase maximum HP and refill the new amount.", &"stat", RARITY_COMMON, &"", &"", &"player_max_hp", PLAYER_MAX_HEALTH_STEP, 1.0)


func _max_hp_legendary_choice() -> Dictionary:
	var current := 50.0 + _player_max_health_bonus
	return _choice(CHOICE_PLAYER_MAX_HP_LEGENDARY, "Player max HP +40", "Max HP %.0f -> %.0f" % [current, current + PLAYER_MAX_HEALTH_LEGENDARY_STEP], "Legendary survivability boost and refill.", &"stat", RARITY_LEGENDARY, &"", &"", &"player_max_hp", PLAYER_MAX_HEALTH_LEGENDARY_STEP, 0.5)


func _star_sticker_damage_choice() -> Dictionary:
	var current := _star_sticker_damage(1)
	return _choice(CHOICE_STAR_STICKER_DAMAGE, "Star Sticker damage +2", "Hit %.0f -> %.0f" % [current, current + STAR_STICKER_DAMAGE_STEP], "Sticker hits and pops hit harder.", &"weapon_upgrade", RARITY_COMMON, WEAPON_STAR_STICKER_SWARM, &"", &"star_sticker_damage", STAR_STICKER_DAMAGE_STEP, 1.0)


func _star_sticker_count_choice() -> Dictionary:
	var current := weapon_projectile_count(WEAPON_STAR_STICKER_SWARM, 1)
	return _choice(CHOICE_STAR_STICKER_COUNT, "Star Sticker count +1", "Stars %d -> %d" % [current, mini(MAX_STAR_STICKER_COUNT, current + 1)], "Add exactly one more orbiting sticker.", &"weapon_upgrade", RARITY_RARE, WEAPON_STAR_STICKER_SWARM, &"", &"star_sticker_count", 1.0, 0.75)


func _new_passive_choice() -> Dictionary:
	var next := _passive_level_value(PASSIVE_CANDLE_SPARK, 1) * 100.0
	return _choice(CHOICE_NEW_CANDLE_SPARK, "Candle Spark", "Firelight/Waxlight damage +0%% -> +%.0f%%" % next, "Passive: boosts Firelight/Waxlight-tagged damage broadly.", &"passive", RARITY_UNCOMMON, &"", PASSIVE_CANDLE_SPARK, &"glow_damage_multiplier", next, 1.0)


func _candle_spark_upgrade_choice() -> Dictionary:
	var current_level := _passive_level(PASSIVE_CANDLE_SPARK)
	var current := glow_damage_multiplier() * 100.0
	var next := _passive_level_value(PASSIVE_CANDLE_SPARK, current_level + 1) * 100.0
	return _choice(CHOICE_CANDLE_SPARK_LEVEL, "Candle Spark +1", "Firelight/Waxlight damage +%.0f%% -> +%.0f%%" % [current, next], "Improve Firelight/Waxlight-tagged damage.", &"passive_upgrade", RARITY_UNCOMMON, &"", PASSIVE_CANDLE_SPARK, &"glow_damage_multiplier", next, 1.0)


func _choice(
	choice_id: StringName,
	title: String,
	stat_line: String,
	description: String,
	choice_type: StringName,
	rarity: StringName,
	weapon_id: StringName,
	passive_id: StringName,
	stat_id: StringName,
	value: float,
	draft_weight: float
) -> Dictionary:
	return {
		"id": choice_id,
		"title": title,
		"stat_line": stat_line,
		"description": description,
		"choice_type": choice_type,
		"category_label": _category_label(choice_type),
		"rarity": rarity,
		"rarity_label": _rarity_label(rarity),
		"weapon_id": weapon_id,
		"passive_id": passive_id,
		"stat_id": stat_id,
		"value": value,
		"draft_weight": draft_weight,
	}


func _weighted_unique_choices(eligible_choices: Array[Dictionary], count: int, seed: int) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var remaining := eligible_choices.duplicate(true)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	while result.size() < count and not remaining.is_empty():
		var rarity := _weighted_rarity(rng)
		var rarity_pool := _choices_with_rarity(remaining, rarity)
		if rarity_pool.is_empty():
			rarity_pool = remaining
		var category := _weighted_category(rarity_pool, rng)
		var category_pool := _choices_with_category(rarity_pool, category)
		var choice := _weighted_choice(category_pool if not category_pool.is_empty() else rarity_pool, rng)
		result.append(choice)
		_remove_choice_by_id(remaining, choice.get("id", &""))
	return _first_unique_choices(result + _fallback_choices(), count)


func _weighted_rarity(rng: RandomNumberGenerator) -> StringName:
	var total := 0.0
	for rarity in RARITY_ORDER:
		total += float(RARITY_WEIGHTS[rarity])
	var roll := rng.randf_range(0.0, total)
	var cursor := 0.0
	for rarity in RARITY_ORDER:
		cursor += float(RARITY_WEIGHTS[rarity])
		if roll <= cursor:
			return rarity
	return RARITY_COMMON


func _weighted_category(choices: Array[Dictionary], rng: RandomNumberGenerator) -> StringName:
	var categories := {}
	for choice in choices:
		var category: StringName = choice.get("choice_type", &"fallback")
		categories[category] = float(categories.get(category, 0.0)) + float(CATEGORY_WEIGHTS.get(category, 1.0))
	var total := 0.0
	for value in categories.values():
		total += float(value)
	var roll := rng.randf_range(0.0, total)
	var cursor := 0.0
	for category in categories.keys():
		cursor += float(categories[category])
		if roll <= cursor:
			return category
	return choices[0].get("choice_type", &"fallback")


func _weighted_choice(choices: Array[Dictionary], rng: RandomNumberGenerator) -> Dictionary:
	var total := 0.0
	for choice in choices:
		total += maxf(0.001, float(choice.get("draft_weight", 1.0)))
	var roll := rng.randf_range(0.0, total)
	var cursor := 0.0
	for choice in choices:
		cursor += maxf(0.001, float(choice.get("draft_weight", 1.0)))
		if roll <= cursor:
			return choice
	return choices[0]


func _choices_with_rarity(choices: Array[Dictionary], rarity: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for choice in choices:
		if choice.get("rarity", &"") == rarity:
			result.append(choice)
	return result


func _choices_with_category(choices: Array[Dictionary], category: StringName) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for choice in choices:
		if choice.get("choice_type", &"") == category:
			result.append(choice)
	return result


func _remove_choice_by_id(choices: Array[Dictionary], choice_id: StringName) -> void:
	for index in range(choices.size() - 1, -1, -1):
		if choices[index].get("id", &"") == choice_id:
			choices.remove_at(index)
			return


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
		result.append(_choice(fallback_id, "Patch Up", "Heal 0 -> 5", "Fallback heal keeps drafts at three choices.", &"fallback", RARITY_COMMON, &"", &"", &"heal", 5.0, 0.1))
	return result


func _fallback_choices() -> Array[Dictionary]:
	return [
		_choice(&"fallback_heal", "Patch Up", "Heal 0 -> 5", "Fallback heal keeps drafts at three choices.", &"fallback", RARITY_COMMON, &"", &"", &"heal", 5.0, 0.1),
		_choice(&"fallback_color_pull", "Color Pull", "Pickup feel unchanged", "Fallback utility card for empty pools.", &"fallback", RARITY_COMMON, &"", &"", &"utility", 1.0, 0.1),
		_choice(&"fallback_paper_guard", "Paper Guard", "Guard 0 -> 1", "Fallback survival card for empty pools.", &"fallback", RARITY_COMMON, &"", &"", &"guard", 1.0, 0.1),
	]


func _is_weapon_pick_level(run_level: int) -> bool:
	return WEAPON_PICK_LEVELS.has(run_level)


func _draft_seed_for_level(run_level: int) -> int:
	return _draft_seed + run_level * 7919 + _owned_weapon_levels.size() * 397 + _owned_passive_levels.size() * 53


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
	var base := _waxlight_base_cooldown()
	return weapon_cooldown_seconds(WEAPON_WAXLIGHT_COMET, base)


func _waxlight_base_cooldown() -> float:
	var base := 1.15
	var weapon := _weapon_data(WEAPON_WAXLIGHT_COMET)
	if weapon != null:
		base = float(weapon.level_data_for(1).cooldown_seconds)
	return base


func _star_sticker_damage(level: int) -> float:
	var weapon := _weapon_data(WEAPON_STAR_STICKER_SWARM)
	if weapon == null:
		return 0.0
	return weapon_damage(WEAPON_STAR_STICKER_SWARM, float(weapon.level_data_for(level).base_damage))


func _weapon_data(weapon_id: StringName) -> Resource:
	if _content_factory == null:
		return null
	if _content_factory.has_method("weapon_for_id"):
		return _content_factory.weapon_for_id(weapon_id)
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
	return CANDLE_SPARK_FALLBACK_STEP * float(level)


func _weapon_material_tags(weapon_id: StringName) -> Array[StringName]:
	var weapon := _weapon_data(weapon_id)
	if weapon != null and "material_tags" in weapon:
		return weapon.material_tags
	return []


func _tags_match_candle_spark(damage_tags: Array) -> bool:
	if glow_damage_multiplier() <= 0.0:
		return false
	for tag in damage_tags:
		if tag == &"waxlight" or tag == &"firelight":
			return true
	return false


func _weapon_display_name(weapon_id: StringName) -> String:
	var weapon := _weapon_data(weapon_id)
	if weapon != null and "display_name" in weapon:
		return weapon.display_name
	return String(weapon_id).capitalize()


func _category_label(choice_type: StringName) -> String:
	match choice_type:
		&"weapon":
			return "New Weapon"
		&"weapon_upgrade":
			return "Weapon Upgrade"
		&"passive":
			return "Passive"
		&"passive_upgrade":
			return "Passive Upgrade"
		&"stat":
			return "Stat"
	return "Fallback"


func _rarity_label(rarity: StringName) -> String:
	return String(rarity).capitalize()


func _stat_event(choice_id: StringName) -> Dictionary:
	return {
		"choice_id": choice_id,
		"waxlight_damage_bonus": _waxlight_damage_bonus,
		"waxlight_cooldown_reduction_seconds": _waxlight_cooldown_reduction_seconds,
		"waxlight_cooldown_multiplier": waxlight_cooldown_multiplier(),
		"waxlight_active_duration_bonus": _waxlight_active_duration_bonus,
		"waxlight_unactivated_mark_cap_bonus": _waxlight_unactivated_mark_cap_bonus,
	}


func _health_event(choice_id: StringName, delta: float) -> Dictionary:
	return {
		"choice_id": choice_id,
		"player_max_health_delta": delta,
		"player_max_health_bonus": _player_max_health_bonus,
	}


func _add_weapon(choice_id: StringName, weapon_id: StringName) -> Dictionary:
	if not _can_add_weapon(weapon_id):
		return {}
	_owned_weapon_levels[weapon_id] = 1
	return {
		"choice_id": choice_id,
		"new_weapon_id": weapon_id,
		"weapon_level": 1,
	}


func _passive_event(choice_id: StringName, is_new: bool) -> Dictionary:
	var event := {
		"choice_id": choice_id,
		"passive_level": _passive_level(PASSIVE_CANDLE_SPARK),
		"glow_damage_multiplier": glow_damage_multiplier(),
	}
	if is_new:
		event["new_passive_id"] = PASSIVE_CANDLE_SPARK
	else:
		event["passive_id"] = PASSIVE_CANDLE_SPARK
	return event
