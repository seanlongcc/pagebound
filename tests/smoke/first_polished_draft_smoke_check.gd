extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var state = RunUpgradeStateScript.new()
	state.configure(PrototypeContentFactoryScript.new())
	state.debug_set_draft_seed(42)

	_assert_true(state.owned_weapon_ids() == [&"waxlight_comet"], "run must start with Waxlight Comet only", failures)
	_assert_true(state.weapon_level(&"waxlight_comet") == 1, "Waxlight Comet must start at level 1", failures)
	_assert_true(state.owned_passive_ids().is_empty(), "run must start with no passive items", failures)
	_assert_true(state.has_method("page_event_reward_choices"), "upgrade state must expose Page Event reward drafts", failures)

	var normal_choices: Array[Dictionary] = state.prototype_choices_for_level(2)
	_assert_true(normal_choices.size() == 3, "normal draft must show exactly 3 choices", failures)
	_assert_true(_contains_target(normal_choices, &"weapon_upgrade", &"waxlight_comet"), "normal draft must include legal Waxlight +1 upgrade", failures)
	_assert_true(_contains_new_gear(normal_choices), "expanded normal draft may offer legal second-batch gear", failures)
	_assert_true(_contains_choice_id(normal_choices, &"new_weapon_star_sticker_swarm") or _contains_any_requested_passive(normal_choices), "expanded pool must use authored Star Sticker/passive gear, not fixed weapon-pick levels", failures)
	_assert_choices_have_unique_tags(normal_choices, failures)

	if state.has_method("page_event_reward_choices"):
		var event_choices: Array[Dictionary] = state.page_event_reward_choices(2)
		_assert_true(event_choices.size() == 3, "Page Event reward draft must show exactly 3 choices", failures)
		_assert_true(_contains_new_gear(event_choices), "Page Event reward must guarantee legal new gear while legal", failures)

	var wax_upgrade: Dictionary = state.apply_choice(&"weapon_upgrade_waxlight_comet")
	_assert_true(not wax_upgrade.is_empty(), "Waxlight +1 upgrade must apply", failures)
	_assert_true(state.weapon_level(&"waxlight_comet") == 2, "Waxlight +1 upgrade must add exactly one weapon level", failures)

	var candle_new: Dictionary = state.apply_choice(&"new_passive_candle_spark")
	_assert_true(not candle_new.is_empty(), "Candle Spark acquisition must apply", failures)
	_assert_true(state.passive_level(&"candle_spark") == 1, "Candle Spark must enter at level 1", failures)

	var candle_upgrade: Dictionary = state.apply_choice(&"passive_upgrade_candle_spark")
	_assert_true(not candle_upgrade.is_empty(), "Candle Spark +1 upgrade must apply", failures)
	_assert_true(state.passive_level(&"candle_spark") == 2, "Candle Spark +1 upgrade must add exactly one item level", failures)

	if state.has_method("page_event_reward_choices"):
		var event_after_candle: Array[Dictionary] = state.page_event_reward_choices(3)
		_assert_true(not _contains_choice_id(event_after_candle, &"new_passive_candle_spark"), "Page Event guarantee must not offer already-owned Candle Spark as new gear", failures)
		_assert_true(_contains_new_gear(event_after_candle) or _contains_target(event_after_candle, &"passive_upgrade", &"candle_spark"), "after Candle Spark, event rewards must use remaining legal gear or owned item upgrades", failures)

	_finish(failures)


func _contains_choice_id(choices: Array[Dictionary], choice_id: StringName) -> bool:
	for choice in choices:
		if choice.get("id", &"") == choice_id:
			return true
	return false


func _contains_choice_type(choices: Array[Dictionary], choice_type: StringName) -> bool:
	for choice in choices:
		if choice.get("choice_type", &"") == choice_type:
			return true
	return false


func _contains_new_gear(choices: Array[Dictionary]) -> bool:
	return _contains_choice_type(choices, &"weapon") or _contains_choice_type(choices, &"passive")


func _contains_any_requested_passive(choices: Array[Dictionary]) -> bool:
	for passive_id in [&"candle_spark", &"cloud_seed", &"dream_thread", &"ribbon_spool", &"moon_button"]:
		if _contains_target(choices, &"passive", passive_id):
			return true
	return false


func _contains_target(choices: Array[Dictionary], choice_type: StringName, target_id: StringName) -> bool:
	for choice in choices:
		if choice.get("choice_type", &"") != choice_type:
			continue
		if choice.get("weapon_id", &"") == target_id or choice.get("passive_id", &"") == target_id:
			return true
	return false


func _assert_choices_have_unique_tags(choices: Array[Dictionary], failures: Array[String]) -> void:
	for choice in choices:
		var seen := {}
		for tag in choice.get("tags", []):
			_assert_true(not seen.has(tag), "draft choice %s must not repeat displayed tag %s" % [str(choice.get("id", &"")), str(tag)], failures)
			seen[tag] = true


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("first polished draft smoke check passed")
		quit(0)
		return

	push_error("first polished draft smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
