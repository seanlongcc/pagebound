class_name WeaponUpgradePool
extends RefCounted

const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const WEAPON_STAR_STICKER_SWARM := &"star_sticker_swarm"
const RARITY_COMMON := &"common"
const RARITY_UNCOMMON := &"uncommon"
const RARITY_RARE := &"rare"
const RARITY_EPIC := &"epic"
const RARITY_LEGENDARY := &"legendary"
const POOLS := {
	WEAPON_WAXLIGHT_COMET: [
		{"name": "Comet Hit", "scope": "base projectile", "stat": &"damage", "note": "Scales direct comet hit."},
		{"name": "Impact Radius", "scope": "AoE mark", "stat": &"size", "note": "Scales Waxlight burst footprint."},
		{"name": "Comet Cadence", "scope": "base projectile", "stat": &"cadence", "note": "Waxlight Comet fires more often."},
		{"name": "Dash Burst", "scope": "dash payoff", "stat": &"damage", "note": "L5 crossed marks burst harder."},
		{"name": "Comet Count", "scope": "cast", "stat": &"effect_count", "note": "Adds Waxlight Comets per cast."},
		{"name": "Mark Cap", "scope": "AoE marks", "stat": &"active_cap", "note": "More unactivated Waxlight marks can wait on the page."},
		{"name": "Burst Burn", "scope": "AoE mark", "stat": &"damage", "note": "Mark burst damage rises."},
		{"name": "Comet Reach", "scope": "weapon range", "stat": &"range", "note": "Scales target range and any unlocked connected-mark reach."},
		{"name": "Chain Burst", "scope": "connected marks", "stat": &"damage", "note": "L10 connected bursts hit harder."},
		{"name": "Wax Sustain", "scope": "active wax", "stat": &"duration", "note": "Extends L5 active marks and the L10 connected active window."},
	],
	WEAPON_STAR_STICKER_SWARM: [
		{"name": "Star Strike", "scope": "orbit star", "stat": &"damage", "note": "Scales star contact hit."},
		{"name": "Star Reach", "scope": "weapon range", "stat": &"range", "note": "Scales target range and any unlocked node ricochet range."},
		{"name": "Star Node Cap", "scope": "Star node", "stat": &"active_cap", "note": "Raises persistent Star node cap."},
		{"name": "Ricochet Hit", "scope": "node ricochet", "stat": &"damage", "note": "L5 node ricochet damage."},
		{"name": "Extra Stars", "scope": "orbit star", "stat": &"effect_count", "note": "Adds orbiting stars."},
		{"name": "Dash Volley", "scope": "dash payoff", "stat": &"damage", "note": "L10 node-fired stars inherit stronger Star damage."},
	],
}


func pool_for(weapon_id: StringName, current_level: int = 0) -> Array:
	var rows: Array = POOLS.get(weapon_id, [])
	var next_level := mini(10, current_level + 1)
	var result: Array = []
	for row in rows:
		var min_next_level := int((row as Dictionary).get("min_next_level", 0))
		if min_next_level > 0 and next_level < min_next_level:
			continue
		result.append(row)
	return result


func weapon_id_from_choice(choice_id: StringName) -> StringName:
	var choice_text := String(choice_id)
	for weapon_id in POOLS.keys():
		var prefix := "weapon_upgrade_%s" % String(weapon_id)
		if choice_text == prefix or choice_text.begins_with("%s_" % prefix):
			return weapon_id
	return &""


func rolled_rarity(draft_seed_for_level: int, weapon_id: StringName, option_index: int, weapon_level: int) -> StringName:
	var rng := RandomNumberGenerator.new()
	rng.seed = draft_seed_for_level + String(weapon_id).hash() + option_index * 104729 + weapon_level * 1009
	return _roll_rarity(rng)


func _roll_rarity(rng: RandomNumberGenerator) -> StringName:
	var roll := rng.randf_range(0.0, 100.0)
	var cumulative := 60.0
	if roll < cumulative:
		return RARITY_COMMON
	cumulative += 25.0
	if roll < cumulative:
		return RARITY_UNCOMMON
	cumulative += 9.0
	if roll < cumulative:
		return RARITY_RARE
	cumulative += 5.0
	if roll < cumulative:
		return RARITY_EPIC
	return RARITY_LEGENDARY
