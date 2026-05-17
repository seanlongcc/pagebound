class_name DraftChoicePicker
extends RefCounted

const NEW_WEAPON := &"new_weapon"
const NEW_PASSIVE := &"new_passive"
const WEAPON_UPGRADE := &"weapon_upgrade"
const PASSIVE_UPGRADE := &"passive_upgrade"
const OVERFLOW := &"overflow"
const FAMILY_GEAR := &"gear"
const FAMILY_UPGRADE := &"upgrade"
const NORMAL_UPGRADE_CHANCE := 0.70


func normal_choices(legal_choices: Dictionary, count: int, seed: int, guarantee_new_gear: bool = false) -> Array[Dictionary]:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed
	var result: Array[Dictionary] = []
	if guarantee_new_gear:
		var guaranteed := _roll_family(FAMILY_GEAR, legal_choices, rng, result)
		if not guaranteed.is_empty():
			result.append(guaranteed)
	while result.size() < count:
		var choice := _roll_card(legal_choices, rng, result)
		if choice.is_empty():
			break
		result.append(choice)
	return _fill_to_count(result, legal_choices, count, rng)


func _roll_card(legal_choices: Dictionary, rng: RandomNumberGenerator, selected: Array[Dictionary]) -> Dictionary:
	var preferred_family := FAMILY_UPGRADE if rng.randf() < NORMAL_UPGRADE_CHANCE else FAMILY_GEAR
	var choice := _roll_family(preferred_family, legal_choices, rng, selected)
	if not choice.is_empty():
		return choice
	var fallback_family := FAMILY_GEAR if preferred_family == FAMILY_UPGRADE else FAMILY_UPGRADE
	choice = _roll_family(fallback_family, legal_choices, rng, selected)
	if not choice.is_empty():
		return choice
	return _pick_category(OVERFLOW, legal_choices, rng, selected)


func _roll_family(family: StringName, legal_choices: Dictionary, rng: RandomNumberGenerator, selected: Array[Dictionary]) -> Dictionary:
	var first_category := WEAPON_UPGRADE
	var second_category := PASSIVE_UPGRADE
	if family == FAMILY_GEAR:
		first_category = NEW_WEAPON
		second_category = NEW_PASSIVE
	if rng.randf() >= 0.50:
		var swap := first_category
		first_category = second_category
		second_category = swap
	var choice := _pick_category(first_category, legal_choices, rng, selected)
	if not choice.is_empty():
		return choice
	return _pick_category(second_category, legal_choices, rng, selected)


func _pick_category(category: StringName, legal_choices: Dictionary, rng: RandomNumberGenerator, selected: Array[Dictionary]) -> Dictionary:
	var pool: Array = legal_choices.get(category, [])
	if pool.is_empty():
		return {}
	var unique_pool := _without_selected_signatures(pool, selected)
	if not unique_pool.is_empty():
		return unique_pool[rng.randi_range(0, unique_pool.size() - 1)].duplicate(true)
	if _has_unused_distinct_choice(legal_choices, selected):
		return {}
	return pool[rng.randi_range(0, pool.size() - 1)].duplicate(true)


func _fill_to_count(result: Array[Dictionary], legal_choices: Dictionary, count: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	while result.size() < count:
		var choice := _pick_any(legal_choices, rng, result)
		if choice.is_empty():
			break
		result.append(choice)
	return result


func _pick_any(legal_choices: Dictionary, rng: RandomNumberGenerator, selected: Array[Dictionary]) -> Dictionary:
	for category in [NEW_WEAPON, NEW_PASSIVE, WEAPON_UPGRADE, PASSIVE_UPGRADE, OVERFLOW]:
		var choice := _pick_category(category, legal_choices, rng, selected)
		if not choice.is_empty():
			return choice
	return {}


func _without_selected_signatures(pool: Array, selected: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var selected_signatures := {}
	for choice in selected:
		selected_signatures[_choice_signature(choice)] = true
	for choice in pool:
		if not selected_signatures.has(_choice_signature(choice)):
			result.append((choice as Dictionary).duplicate(true))
	return result


func _has_unused_distinct_choice(legal_choices: Dictionary, selected: Array[Dictionary]) -> bool:
	var selected_signatures := {}
	for choice in selected:
		selected_signatures[_choice_signature(choice)] = true
	for category in [NEW_WEAPON, NEW_PASSIVE, WEAPON_UPGRADE, PASSIVE_UPGRADE]:
		for choice in legal_choices.get(category, []):
			if not selected_signatures.has(_choice_signature(choice)):
				return true
	return false


func _choice_signature(choice: Dictionary) -> String:
	var target := String(choice.get("weapon_id", &""))
	if target == "":
		target = String(choice.get("passive_id", &""))
	if target == "":
		target = String(choice.get("stat_id", &""))
	if String(choice.get("choice_type", &"")).ends_with("upgrade") and String(choice.get("stat_id", &"")) != "":
		target = "%s:%s" % [target, String(choice.get("stat_id", &""))]
	return "%s:%s" % [String(choice.get("choice_type", &"")), target]
