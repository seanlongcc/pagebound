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
	_assert_true(_rarity_present(eligible, &"rare"), "rare choices must be eligible in normal drafts", failures)
	_assert_true(_rarity_present(eligible, &"epic"), "epic choices must be eligible in normal drafts", failures)
	_assert_true(_rarity_present(eligible, &"legendary"), "legendary choices must be eligible in normal drafts", failures)

	var upgrade_cards := 0
	var new_gear_cards := 0
	for seed in 200:
		if state.has_method("debug_set_draft_seed"):
			state.debug_set_draft_seed(seed)
		var choices: Array[Dictionary] = state.prototype_choices_for_level(3)
		_assert_true(choices.size() == 3, "seeded draft must keep exactly 3 choices", failures)
		_assert_true(_stays_inside_first_package(choices), "seeded draft must stay inside first polished package", failures)
		upgrade_cards += _choice_type_count(choices, &"weapon_upgrade") + _choice_type_count(choices, &"passive_upgrade")
		new_gear_cards += _choice_type_count(choices, &"passive")
	_assert_true(upgrade_cards > new_gear_cards, "normal drafts must bias toward upgrade cards over new gear in tiny pool", failures)

	_finish(failures)


func _rarity_present(choices: Array[Dictionary], rarity: StringName) -> bool:
	for choice in choices:
		if choice.get("rarity", &"") == rarity:
			return true
	return false


func _stays_inside_first_package(choices: Array[Dictionary]) -> bool:
	for choice in choices:
		var id: StringName = choice.get("id", &"")
		if id != &"weapon_upgrade_waxlight_comet" and id != &"new_passive_candle_spark" and id != &"passive_upgrade_candle_spark":
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
