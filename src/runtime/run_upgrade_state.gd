class_name RunUpgradeState
extends RefCounted

const DraftChoicePickerScript := preload("res://src/runtime/draft_choice_picker.gd")

const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const WEAPON_STAR_STICKER_SWARM := &"star_sticker_swarm"
const PASSIVE_CANDLE_SPARK := &"candle_spark"
const PASSIVE_CLOUD_SEED := &"cloud_seed"
const PASSIVE_DREAM_THREAD := &"dream_thread"
const PASSIVE_RIBBON_SPOOL := &"ribbon_spool"
const PASSIVE_MOON_BUTTON := &"moon_button"
const MAX_WEAPONS := 5
const MAX_PASSIVES := 5
const DRAFT_CHOICE_COUNT := 3
const BASE_PLAYER_MAX_HEALTH := 1000.0
const LEGACY_RANGE_STEP := 1.5
const RARITY_COMMON := &"common"
const RARITY_UNCOMMON := &"uncommon"
const RARITY_RARE := &"rare"
const RARITY_EPIC := &"epic"
const RARITY_LEGENDARY := &"legendary"
const STAT_PERCENT_BY_RARITY := {
	RARITY_COMMON: 0.10,
	RARITY_UNCOMMON: 0.20,
	RARITY_RARE: 0.35,
	RARITY_EPIC: 0.50,
	RARITY_LEGENDARY: 0.75,
}
const COUNT_BY_RARITY := {
	RARITY_COMMON: 1,
	RARITY_UNCOMMON: 1,
	RARITY_RARE: 2,
	RARITY_EPIC: 2,
	RARITY_LEGENDARY: 3,
}
const WEAPON_UPGRADE_TRACKS := {
	WEAPON_WAXLIGHT_COMET: [
		{"name": "Comet Hit", "scope": "base projectile", "stat": &"damage", "rarity": RARITY_COMMON, "note": "Scales direct comet hit."},
		{"name": "Impact Splat", "scope": "impact mark", "stat": &"size", "rarity": RARITY_COMMON, "note": "Scales splat footprint."},
		{"name": "Wax Trail", "scope": "Pagecraft trail", "stat": &"duration", "rarity": RARITY_COMMON, "note": "Trails remain longer."},
		{"name": "Spark Release", "scope": "impact proc", "stat": &"proc_chance", "rarity": RARITY_UNCOMMON, "note": "L5 fork sparks plus release chance."},
		{"name": "Trail Width", "scope": "Pagecraft trail", "stat": &"size", "rarity": RARITY_RARE, "note": "Trails become wider."},
		{"name": "Trail Burn", "scope": "Pagecraft trail", "stat": &"damage", "rarity": RARITY_RARE, "note": "Trail and activation damage rises."},
		{"name": "Spark Count", "scope": "impact proc", "stat": &"effect_count", "rarity": RARITY_UNCOMMON, "note": "Adds more sparks."},
		{"name": "Spark Reach", "scope": "impact proc", "stat": &"range", "rarity": RARITY_EPIC, "note": "Sparks travel farther."},
		{"name": "Dash Ignition", "scope": "dash payoff", "stat": &"damage", "rarity": RARITY_RARE, "note": "L10 highway plus stronger dash slash."},
	],
	WEAPON_STAR_STICKER_SWARM: [
		{"name": "Star Strike", "scope": "orbit star", "stat": &"damage", "rarity": RARITY_COMMON, "note": "Scales star contact hit."},
		{"name": "Orbit Reach", "scope": "orbit star", "stat": &"range", "rarity": RARITY_COMMON, "note": "Stars reach farther from player."},
		{"name": "Star Node", "scope": "Pagecraft node", "stat": &"duration", "rarity": RARITY_COMMON, "note": "Nodes remain longer."},
		{"name": "Ricochet Hit", "scope": "node ricochet", "stat": &"damage", "rarity": RARITY_UNCOMMON, "note": "L5 node ricochet damage."},
		{"name": "Ricochet Reach", "scope": "node ricochet", "stat": &"range", "rarity": RARITY_UNCOMMON, "note": "Ricochets find farther nodes."},
		{"name": "Extra Stars", "scope": "orbit star", "stat": &"effect_count", "rarity": RARITY_RARE, "note": "Adds orbiting stars."},
		{"name": "Node Spawn", "scope": "star hit proc", "stat": &"proc_chance", "rarity": RARITY_RARE, "note": "Chance to leave a node."},
		{"name": "Node Pop", "scope": "Pagecraft node", "stat": &"size", "rarity": RARITY_EPIC, "note": "Node pop footprint grows."},
		{"name": "Dash Launch", "scope": "dash payoff", "stat": &"damage", "rarity": RARITY_RARE, "note": "L10 constellation rain plus stronger launched nodes."},
	],
}

var _content_factory
var _draft_picker = DraftChoicePickerScript.new()
var _owned_weapon_levels: Dictionary = {}
var _owned_passive_levels: Dictionary = {}
var _weapon_stat_bonuses: Dictionary = {}
var _weapon_range_bonuses: Dictionary = {}
var _weapon_applied_upgrades: Dictionary = {}
var _draft_seed := 1337
var _player_health_ratio := 1.0


func _init() -> void:
	reset()


func configure(content_factory) -> void:
	_content_factory = content_factory


func reset() -> void:
	_owned_weapon_levels = {WEAPON_WAXLIGHT_COMET: 1}
	_owned_passive_levels = {}
	_weapon_stat_bonuses = {}
	_weapon_range_bonuses = {}
	_weapon_applied_upgrades = {}
	_player_health_ratio = 1.0


func prototype_choices_for_level(run_level: int) -> Array[Dictionary]:
	return _draft_choices(run_level, false)


func page_event_reward_choices(run_level: int = 0) -> Array[Dictionary]:
	return _draft_choices(run_level, true)


func prototype_choices() -> Array[Dictionary]:
	return prototype_choices_for_level(2)


func apply_choice(choice_id: StringName) -> Dictionary:
	var choice_text := String(choice_id)
	if choice_text.begins_with("new_weapon_"):
		return _add_weapon(choice_id, StringName(choice_text.substr(11)))
	if choice_text.begins_with("weapon_upgrade_"):
		return _apply_weapon_level_upgrade(choice_id, StringName(choice_text.substr(15)))
	if choice_text.begins_with("new_passive_"):
		return _add_passive(choice_id, StringName(choice_text.substr(12)))
	if choice_text.begins_with("passive_upgrade_"):
		return _upgrade_passive(choice_id, StringName(choice_text.substr(16)))
	if choice_id == &"waxlight_range_plus":
		return _add_weapon_range(choice_id, WEAPON_WAXLIGHT_COMET, LEGACY_RANGE_STEP)
	return {}


func weapon_damage(weapon_id: StringName, base_damage: float, damage_tags: Array = []) -> float:
	var damage := base_damage * (1.0 + _weapon_stat_bonus(weapon_id, &"damage"))
	var tags := damage_tags
	if tags.is_empty():
		tags = _weapon_material_tags(weapon_id)
	return damage_for_tags(weapon_id, damage, tags)


func damage_for_tags(_source_id: StringName, base_damage: float, damage_tags: Array) -> float:
	if _tags_match_passive(PASSIVE_CANDLE_SPARK, damage_tags):
		return base_damage * (1.0 + _passive_stat_bonus(&"damage"))
	return base_damage


func weapon_projectile_count(weapon_id: StringName, base_count: int) -> int:
	return clampi(base_count + int(_weapon_stat_bonus(weapon_id, &"effect_count")), 1, 8)


func weapon_cooldown_seconds(weapon_id: StringName, base_cooldown_seconds: float) -> float:
	var cadence := cadence_multiplier() * (1.0 + _weapon_stat_bonus(weapon_id, &"cadence"))
	return maxf(0.15, base_cooldown_seconds / maxf(0.1, cadence))


func weapon_range_meters(weapon_id: StringName, base_range_meters: float) -> float:
	var multiplier := range_multiplier() * (1.0 + _weapon_stat_bonus(weapon_id, &"range"))
	return base_range_meters * multiplier + float(_weapon_range_bonuses.get(weapon_id, 0.0))


func weapon_mark_radius_meters(weapon_id: StringName, base_radius_meters: float) -> float:
	return base_radius_meters * size_multiplier() * (1.0 + _weapon_stat_bonus(weapon_id, &"size"))


func star_sticker_lifetime_seconds(base_duration_seconds: float) -> float:
	return base_duration_seconds * duration_multiplier() * (1.0 + _weapon_stat_bonus(WEAPON_STAR_STICKER_SWARM, &"duration"))


func waxlight_active_duration_seconds(base_duration_seconds: float) -> float:
	return base_duration_seconds * duration_multiplier() * (1.0 + _weapon_stat_bonus(WEAPON_WAXLIGHT_COMET, &"duration"))


func waxlight_unactivated_mark_cap(base_cap: int) -> int:
	return base_cap + int(_weapon_stat_bonus(WEAPON_WAXLIGHT_COMET, &"active_cap"))


func waxlight_damage_bonus() -> float:
	return _weapon_stat_bonus(WEAPON_WAXLIGHT_COMET, &"damage")


func waxlight_cooldown_multiplier() -> float:
	return 1.0 / cadence_multiplier()


func player_max_health_bonus() -> float:
	return 0.0


func glow_damage_multiplier() -> float:
	return _passive_stat_bonus(&"damage")


func size_multiplier() -> float:
	return 1.0 + _passive_stat_bonus(&"size")


func duration_multiplier() -> float:
	return 1.0 + _passive_stat_bonus(&"duration")


func range_multiplier() -> float:
	return 1.0 + _passive_stat_bonus(&"range")


func cadence_multiplier() -> float:
	var bonus := _passive_stat_bonus(&"cadence")
	if _passive_level(PASSIVE_MOON_BUTTON) >= 5 and _player_health_ratio <= 0.5:
		bonus += 0.10
	return 1.0 + bonus


func set_player_health_ratio(ratio: float) -> void:
	_player_health_ratio = clampf(ratio, 0.0, 1.0)


func owned_weapon_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _owned_weapon_levels.keys():
		ids.append(id)
	return ids


func owned_passive_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for id in _owned_passive_levels.keys():
		ids.append(id)
	return ids


func weapon_levels() -> Dictionary:
	return _owned_weapon_levels.duplicate(true)


func passive_levels() -> Dictionary:
	return _owned_passive_levels.duplicate(true)


func weapon_applied_upgrades() -> Dictionary:
	return _weapon_applied_upgrades.duplicate(true)


func weapon_level(weapon_id: StringName) -> int:
	return _weapon_level(weapon_id)


func passive_level(passive_id: StringName) -> int:
	return _passive_level(passive_id)


func debug_set_draft_seed(seed: int) -> void:
	_draft_seed = seed


func debug_rarity_weights() -> Dictionary:
	return {
		RARITY_COMMON: 60.0,
		RARITY_UNCOMMON: 25.0,
		RARITY_RARE: 9.0,
		RARITY_EPIC: 5.0,
		RARITY_LEGENDARY: 1.0,
	}


func debug_eligible_choices_for_level(_run_level: int) -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	for bucket in _legal_draft_choice_buckets().values():
		for choice in bucket:
			choices.append(choice)
	return choices


func _draft_choices(run_level: int, guarantee_new_gear: bool) -> Array[Dictionary]:
	return _draft_picker.normal_choices(_legal_draft_choice_buckets(), DRAFT_CHOICE_COUNT, _draft_seed_for_level(run_level), guarantee_new_gear)


func _legal_draft_choice_buckets() -> Dictionary:
	var buckets := {
		&"new_weapon": [],
		&"new_passive": [],
		&"weapon_upgrade": [],
		&"passive_upgrade": [],
		&"overflow": [],
	}
	for weapon in _weapon_pool():
		if weapon != null and _can_add_weapon(weapon.id):
			buckets[&"new_weapon"].append(_new_weapon_choice(weapon))
	for passive in _passive_pool():
		if passive != null:
			if _can_add_passive(passive.id):
				buckets[&"new_passive"].append(_new_passive_choice(passive))
			elif _passive_level(passive.id) > 0 and _passive_level(passive.id) < 5:
				buckets[&"passive_upgrade"].append(_passive_upgrade_choice(passive))
	for weapon_id in owned_weapon_ids():
		if _weapon_level(weapon_id) < 10:
			var weapon_choice := _weapon_level_choice(weapon_id)
			if not weapon_choice.is_empty():
				buckets[&"weapon_upgrade"].append(weapon_choice)
	if buckets[&"new_weapon"].is_empty() and buckets[&"new_passive"].is_empty() and buckets[&"weapon_upgrade"].is_empty() and buckets[&"passive_upgrade"].is_empty():
		buckets[&"overflow"] = _fallback_choices()
	return buckets


func _new_weapon_choice(weapon: Resource) -> Dictionary:
	return _choice(
		StringName("new_weapon_%s" % String(weapon.id)),
		weapon.display_name,
		"Level 0 -> 1",
		weapon.description,
		&"weapon",
		weapon.draft_rarity,
		weapon.id,
		&"",
		&"weapon",
		1.0,
		1.0,
		"Icon: weapon",
		weapon.material_tags + weapon.catalyst_tags,
		"Level 0 -> 1",
		"Weapon Slot %d/%d -> %d/%d" % [_owned_weapon_levels.size(), MAX_WEAPONS, _owned_weapon_levels.size() + 1, MAX_WEAPONS],
		"Evolves with %s at Lv10" % _tag_list(weapon.catalyst_tags)
	)


func _weapon_level_choice(weapon_id: StringName) -> Dictionary:
	var weapon := _weapon_data(weapon_id)
	var upgrade := _next_weapon_upgrade(weapon_id)
	if weapon == null or upgrade.is_empty():
		return {}
	var current := _weapon_level(weapon_id)
	var next_level := mini(10, current + 1)
	var rarity: StringName = upgrade["rarity"]
	var stat: StringName = upgrade["stat"]
	var value: float = _upgrade_value_for_stat(stat, rarity)
	return _choice(
		StringName("weapon_upgrade_%s" % String(weapon_id)),
		"%s: %s" % [weapon.display_name, upgrade["name"]],
		"%s %s +%s" % [upgrade["scope"], _stat_label(stat), _value_label(stat, value)],
		upgrade["note"],
		&"weapon_upgrade",
		rarity,
		weapon_id,
		&"",
		stat,
		float(value),
		1.0,
		"Icon: %s" % String(weapon.pagecraft_material_tag).capitalize(),
		weapon.material_tags + weapon.catalyst_tags,
		"Level %d -> %d" % [current, next_level],
		"Weapon Slots %d/%d" % [_owned_weapon_levels.size(), MAX_WEAPONS],
		"Evolves with %s at Lv10" % _tag_list(weapon.catalyst_tags)
	)


func _new_passive_choice(passive: Resource) -> Dictionary:
	var next := _passive_level_value(passive.id, 1)
	return _choice(
		StringName("new_passive_%s" % String(passive.id)),
		passive.display_name,
		"%s +0%% -> +%.0f%%" % [_stat_label(passive.stat_id), next * 100.0],
		_passive_description(passive, 1),
		&"passive",
		passive.draft_rarity,
		&"",
		passive.id,
		passive.stat_id,
		next,
		1.0,
		"Icon: item",
		passive.catalyst_tags,
		"Level 0 -> 1",
		"Item Slot %d/%d -> %d/%d" % [_owned_passive_levels.size(), MAX_PASSIVES, _owned_passive_levels.size() + 1, MAX_PASSIVES],
		"Evolves %s-compatible weapons at Lv5" % _tag_list(passive.catalyst_tags)
	)


func _passive_upgrade_choice(passive: Resource) -> Dictionary:
	var current_level := _passive_level(passive.id)
	var current := _passive_level_value(passive.id, current_level)
	var next := _passive_level_value(passive.id, current_level + 1)
	return _choice(
		StringName("passive_upgrade_%s" % String(passive.id)),
		"%s +1" % passive.display_name,
		"%s +%.0f%% -> +%.0f%%" % [_stat_label(passive.stat_id), current * 100.0, next * 100.0],
		_passive_description(passive, current_level + 1),
		&"passive_upgrade",
		passive.draft_rarity,
		&"",
		passive.id,
		passive.stat_id,
		next,
		1.0,
		"Icon: item",
		passive.catalyst_tags,
		"Level %d -> %d" % [current_level, mini(5, current_level + 1)],
		"Item Slots %d/%d" % [_owned_passive_levels.size(), MAX_PASSIVES],
		"Evolves %s-compatible weapons at Lv5" % _tag_list(passive.catalyst_tags)
	)


func _choice(choice_id: StringName, title: String, stat_line: String, description: String, choice_type: StringName, rarity: StringName, weapon_id: StringName, passive_id: StringName, stat_id: StringName, value: float, draft_weight: float, icon_label: String, tags: Array, level_line: String, slot_line: String, compatibility_hint: String) -> Dictionary:
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
		"icon_label": icon_label,
		"tags": _string_name_array(tags),
		"level_line": level_line,
		"slot_line": slot_line,
		"compatibility_hint": compatibility_hint,
	}


func _add_weapon(choice_id: StringName, weapon_id: StringName) -> Dictionary:
	if not _can_add_weapon(weapon_id):
		return {}
	_owned_weapon_levels[weapon_id] = 1
	return {"choice_id": choice_id, "new_weapon_id": weapon_id, "weapon_level": 1}


func _apply_weapon_level_upgrade(choice_id: StringName, weapon_id: StringName) -> Dictionary:
	if not _owned_weapon_levels.has(weapon_id) or _weapon_level(weapon_id) >= 10:
		return {}
	var upgrade := _next_weapon_upgrade(weapon_id)
	if upgrade.is_empty():
		return {}
	_owned_weapon_levels[weapon_id] = mini(10, _weapon_level(weapon_id) + 1)
	var stat: StringName = upgrade["stat"]
	var value: float = _upgrade_value_for_stat(stat, upgrade["rarity"])
	_add_weapon_stat_bonus(weapon_id, stat, value)
	_add_weapon_applied_upgrade(weapon_id, "%s (%s %s)" % [upgrade["name"], upgrade["scope"], _stat_label(stat)])
	return {
		"choice_id": choice_id,
		"weapon_id": weapon_id,
		"weapon_level": _weapon_level(weapon_id),
		"upgrade_name": upgrade["name"],
		"upgrade_scope": upgrade["scope"],
		"stat_id": stat,
		"value": value,
	}


func _add_passive(choice_id: StringName, passive_id: StringName) -> Dictionary:
	if not _can_add_passive(passive_id):
		return {}
	_owned_passive_levels[passive_id] = 1
	return _passive_event(choice_id, passive_id, true)


func _upgrade_passive(choice_id: StringName, passive_id: StringName) -> Dictionary:
	if not _owned_passive_levels.has(passive_id) or _passive_level(passive_id) >= 5:
		return {}
	_owned_passive_levels[passive_id] = mini(5, _passive_level(passive_id) + 1)
	return _passive_event(choice_id, passive_id, false)


func _add_weapon_range(choice_id: StringName, weapon_id: StringName, delta: float) -> Dictionary:
	if not _owned_weapon_levels.has(weapon_id):
		return {}
	_weapon_range_bonuses[weapon_id] = float(_weapon_range_bonuses.get(weapon_id, 0.0)) + delta
	return {"choice_id": choice_id, "weapon_id": weapon_id, "weapon_range_bonus": _weapon_range_bonuses[weapon_id]}


func _passive_event(choice_id: StringName, passive_id: StringName, is_new: bool) -> Dictionary:
	var passive := _passive_data(passive_id)
	var stat_id: StringName = passive.stat_id if passive != null else &""
	var event := {
		"choice_id": choice_id,
		"passive_id": passive_id,
		"passive_level": _passive_level(passive_id),
		"stat_id": stat_id,
		"value": _passive_level_value(passive_id, _passive_level(passive_id)),
	}
	if is_new:
		event["new_passive_id"] = passive_id
	return event


func _next_weapon_upgrade(weapon_id: StringName) -> Dictionary:
	var track: Array = WEAPON_UPGRADE_TRACKS.get(weapon_id, [])
	if track.is_empty():
		return {}
	var index := clampi(_weapon_level(weapon_id) - 1, 0, track.size() - 1)
	if index >= track.size():
		return {}
	return (track[index] as Dictionary).duplicate(true)


func _upgrade_value_for_stat(stat: StringName, rarity: StringName) -> float:
	if stat == &"effect_count" or stat == &"active_cap":
		return float(COUNT_BY_RARITY.get(rarity, 1))
	return float(STAT_PERCENT_BY_RARITY.get(rarity, 0.10))


func _add_weapon_stat_bonus(weapon_id: StringName, stat: StringName, value) -> void:
	var bonuses: Dictionary = _weapon_stat_bonuses.get(weapon_id, {})
	bonuses[stat] = float(bonuses.get(stat, 0.0)) + float(value)
	_weapon_stat_bonuses[weapon_id] = bonuses


func _add_weapon_applied_upgrade(weapon_id: StringName, label: String) -> void:
	var applied: Array = _weapon_applied_upgrades.get(weapon_id, [])
	applied.append(label)
	_weapon_applied_upgrades[weapon_id] = applied


func _weapon_stat_bonus(weapon_id: StringName, stat: StringName) -> float:
	var bonuses: Dictionary = _weapon_stat_bonuses.get(weapon_id, {})
	return float(bonuses.get(stat, 0.0))


func _passive_stat_bonus(stat: StringName) -> float:
	var total := 0.0
	for passive_id in _owned_passive_levels.keys():
		var passive := _passive_data(passive_id)
		if passive != null and passive.stat_id == stat:
			total += _passive_level_value(passive_id, _passive_level(passive_id))
	return total


func _passive_level_value(passive_id: StringName, level: int) -> float:
	var passive := _passive_data(passive_id)
	if passive != null and passive.level_values.size() >= level and level > 0:
		return float(passive.level_values[level - 1])
	return clampf(float(level), 0.0, 5.0) * 0.10


func _can_add_weapon(weapon_id: StringName) -> bool:
	return not _owned_weapon_levels.has(weapon_id) and _owned_weapon_levels.size() < MAX_WEAPONS


func _can_add_passive(passive_id: StringName) -> bool:
	return not _owned_passive_levels.has(passive_id) and _owned_passive_levels.size() < MAX_PASSIVES


func _weapon_level(weapon_id: StringName) -> int:
	return int(_owned_weapon_levels.get(weapon_id, 0))


func _passive_level(passive_id: StringName) -> int:
	return int(_owned_passive_levels.get(passive_id, 0))


func _weapon_data(weapon_id: StringName) -> Resource:
	if _content_factory != null and _content_factory.has_method("weapon_for_id"):
		return _content_factory.weapon_for_id(weapon_id)
	return null


func _passive_data(passive_id: StringName) -> Resource:
	if _content_factory != null and _content_factory.has_method("passive_for_id"):
		return _content_factory.passive_for_id(passive_id)
	if passive_id == PASSIVE_CANDLE_SPARK and _content_factory != null and _content_factory.has_method("candle_spark_passive"):
		return _content_factory.candle_spark_passive()
	return null


func _weapon_pool() -> Array:
	if _content_factory != null and _content_factory.has_method("weapon_pool"):
		return _content_factory.weapon_pool()
	return []


func _passive_pool() -> Array:
	if _content_factory != null and _content_factory.has_method("passive_items"):
		return _content_factory.passive_items()
	return []


func _weapon_material_tags(weapon_id: StringName) -> Array[StringName]:
	var weapon := _weapon_data(weapon_id)
	if weapon != null and "material_tags" in weapon:
		return weapon.material_tags
	return []


func _tags_match_passive(passive_id: StringName, damage_tags: Array) -> bool:
	var passive := _passive_data(passive_id)
	if passive == null:
		return false
	for tag in damage_tags:
		if passive.catalyst_tags.has(tag):
			return true
	return false


func _passive_description(passive: Resource, level: int) -> String:
	var base: String = passive.description
	if level >= 5:
		match passive.id:
			PASSIVE_CANDLE_SPARK:
				return "%s L5: first player-owned hit per enemy deals +10%% damage." % base
			PASSIVE_CLOUD_SEED:
				return "%s L5: every 5th eligible cast gets extra +50%% size." % base
			PASSIVE_DREAM_THREAD:
				return "%s L5: every 5th eligible timed effect gets extra +50%% duration." % base
			PASSIVE_RIBBON_SPOOL:
				return "%s L5: outer 25%% range hits/effects are 10%% stronger." % base
			PASSIVE_MOON_BUTTON:
				return "%s L5: +10%% cadence while HP is at or below 50%%." % base
	return base


func _fallback_choices() -> Array[Dictionary]:
	return [
		_choice(&"overflow_damage_crumb", "Damage Crumb", "Global damage +5%", "Overflow appears only after all normal gear choices are exhausted.", &"overflow", RARITY_COMMON, &"", &"", &"damage", 0.05, 1.0, "Icon: crumb", [], "Overflow", "No open gear upgrades", "No evolution change"),
		_choice(&"overflow_range_crumb", "Range Crumb", "Global range +5%", "Overflow appears only after all normal gear choices are exhausted.", &"overflow", RARITY_COMMON, &"", &"", &"range", 0.05, 1.0, "Icon: crumb", [], "Overflow", "No open gear upgrades", "No evolution change"),
		_choice(&"overflow_size_crumb", "Size Crumb", "Global size +5%", "Overflow appears only after all normal gear choices are exhausted.", &"overflow", RARITY_COMMON, &"", &"", &"size", 0.05, 1.0, "Icon: crumb", [], "Overflow", "No open gear upgrades", "No evolution change"),
	]


func _draft_seed_for_level(run_level: int) -> int:
	return _draft_seed + run_level * 7919 + _owned_weapon_levels.size() * 397 + _owned_passive_levels.size() * 53


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
		&"overflow":
			return "Overflow"
	return "Choice"


func _rarity_label(rarity: StringName) -> String:
	return String(rarity).capitalize()


func _stat_label(stat: StringName) -> String:
	return String(stat).replace("_", " ").capitalize()


func _value_label(stat: StringName, value) -> String:
	if stat == &"effect_count" or stat == &"active_cap":
		return str(int(value))
	return "%.0f%%" % (float(value) * 100.0)


func _tag_list(tags: Array) -> String:
	var names: Array[String] = []
	for tag in tags:
		names.append(String(tag).capitalize())
	return "/".join(names)


func _string_name_array(values: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for value in values:
		var tag := StringName(value)
		if not result.has(tag):
			result.append(tag)
	return result
