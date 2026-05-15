extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var state = RunUpgradeStateScript.new()
	state.configure(PrototypeContentFactoryScript.new())

	_assert_true(state.has_method("debug_rarity_weights"), "upgrade state must expose draft rarity weights", failures)
	_assert_true(state.has_method("debug_set_draft_seed"), "upgrade state must expose deterministic draft seed", failures)
	_assert_true(state.has_method("debug_eligible_choices_for_level"), "upgrade state must expose eligible draft choices", failures)

	if state.has_method("debug_rarity_weights"):
		var weights: Dictionary = state.debug_rarity_weights()
		_assert_true(int(weights.get(&"common", 0)) == 60, "Common rarity weight must be 60", failures)
		_assert_true(int(weights.get(&"uncommon", 0)) == 25, "Uncommon rarity weight must be 25", failures)
		_assert_true(int(weights.get(&"rare", 0)) == 9, "Rare rarity weight must be 9", failures)
		_assert_true(int(weights.get(&"epic", 0)) == 5, "Epic rarity weight must be 5", failures)
		_assert_true(int(weights.get(&"legendary", 0)) == 1, "Legendary rarity weight must be 1", failures)

	var eligible: Array[Dictionary] = []
	if state.has_method("debug_eligible_choices_for_level"):
		eligible = state.debug_eligible_choices_for_level(3)
	_assert_true(_rarity_present(eligible, &"common"), "common choices must be eligible in normal drafts", failures)
	for _upgrade in 5:
		state.apply_choice(&"weapon_upgrade_star_sticker_swarm")
	if state.has_method("debug_eligible_choices_for_level"):
		eligible = state.debug_eligible_choices_for_level(3)
	_assert_true(_rarity_present(eligible, &"rare"), "rare choices must become eligible as Star Sticker progresses", failures)

	var upgrade_cards := 0
	var new_gear_cards := 0
	for seed in 200:
		if state.has_method("debug_set_draft_seed"):
			state.debug_set_draft_seed(seed)
		var choices: Array[Dictionary] = state.prototype_choices_for_level(3)
		_assert_true(choices.size() == 3, "seeded draft must keep exactly 3 choices", failures)
		_assert_true(_uses_allowed_expanded_pool(choices), "seeded draft must stay inside authored expanded prototype pool", failures)
		upgrade_cards += _choice_type_count(choices, &"weapon_upgrade") + _choice_type_count(choices, &"passive_upgrade")
		new_gear_cards += _choice_type_count(choices, &"weapon") + _choice_type_count(choices, &"passive")
	_assert_true(upgrade_cards > 0 and new_gear_cards > 0, "seeded drafts must mix legal upgrades and expanded new gear when both exist", failures)

	_finish(failures)


func _rarity_present(choices: Array[Dictionary], rarity: StringName) -> bool:
	for choice in choices:
		if choice.get("rarity", &"") == rarity:
			return true
	return false


func _uses_allowed_expanded_pool(choices: Array[Dictionary]) -> bool:
	for choice in choices:
		var id: StringName = choice.get("id", &"")
		if id == &"weapon_upgrade_star_sticker_swarm" or id == &"new_weapon_waxlight_comet":
			continue
		if String(id).begins_with("new_passive_") or String(id).begins_with("passive_upgrade_"):
			continue
		if String(id).begins_with("overflow_"):
			continue
		return false
	return true


func _choice_type_count(choices: Array[Dictionary], choice_type: StringName) -> int:
	var count := 0
	for choice in choices:
		if choice.get("choice_type", &"") == choice_type:
			count += 1
	return count


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("draft rarity weights smoke check passed")
		quit(0)
		return

	push_error("draft rarity weights smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
