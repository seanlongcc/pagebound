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

	var high_tier_drafts := 0
	for seed in 200:
		if state.has_method("debug_set_draft_seed"):
			state.debug_set_draft_seed(seed)
		var choices: Array[Dictionary] = state.prototype_choices_for_level(3)
		_assert_true(choices.size() == 3, "seeded draft must keep exactly 3 choices", failures)
		_assert_true(_has_unique_choice_ids(choices), "seeded draft must avoid duplicate choices", failures)
		if _draft_has_high_tier(choices):
			high_tier_drafts += 1
	_assert_true(high_tier_drafts > 0, "seeded weighted drafts must sometimes produce rare-or-better tiers", failures)
	_assert_true(high_tier_drafts < 200, "seeded weighted drafts must not always show rare-or-better tiers", failures)

	_finish(failures)


func _rarity_present(choices: Array[Dictionary], rarity: StringName) -> bool:
	for choice in choices:
		if choice.get("rarity", &"") == rarity:
			return true
	return false


func _draft_has_high_tier(choices: Array[Dictionary]) -> bool:
	for choice in choices:
		var rarity: StringName = choice.get("rarity", &"")
		if rarity == &"rare" or rarity == &"epic" or rarity == &"legendary":
			return true
	return false


func _has_unique_choice_ids(choices: Array[Dictionary]) -> bool:
	var seen := {}
	for choice in choices:
		var id: StringName = choice.get("id", &"")
		if id == &"" or seen.has(id):
			return false
		seen[id] = true
	return true


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
