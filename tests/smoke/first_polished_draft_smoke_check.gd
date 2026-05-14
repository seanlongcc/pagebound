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
	_assert_true(_contains_target(normal_choices, &"passive", &"candle_spark"), "tiny-pool normal draft may offer Candle Spark as legal new gear", failures)
	_assert_true(not _contains_choice_type(normal_choices, &"weapon"), "tiny pool must not offer a new weapon when only starter weapon exists", failures)
	_assert_true(not _contains_choice_id(normal_choices, &"new_weapon_star_sticker_swarm"), "first polished package must not use old fixed weapon-pick levels", failures)

	if state.has_method("page_event_reward_choices"):
		var event_choices: Array[Dictionary] = state.page_event_reward_choices(2)
		_assert_true(event_choices.size() == 3, "Page Event reward draft must show exactly 3 choices", failures)
		_assert_true(_contains_target(event_choices, &"passive", &"candle_spark"), "Page Event reward must guarantee Candle Spark while legal", failures)
		_assert_true(not _contains_choice_type(event_choices, &"weapon"), "Page Event reward must not invent unavailable new weapons", failures)

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
		_assert_true(not _contains_choice_id(event_after_candle, &"new_passive_candle_spark"), "Page Event guarantee must fail gracefully after all new gear is owned", failures)
		_assert_true(_contains_target(event_after_candle, &"passive_upgrade", &"candle_spark"), "owned Candle Spark must upgrade through item upgrade cards", failures)

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


func _contains_target(choices: Array[Dictionary], choice_type: StringName, target_id: StringName) -> bool:
	for choice in choices:
		if choice.get("choice_type", &"") != choice_type:
			continue
		if choice.get("weapon_id", &"") == target_id or choice.get("passive_id", &"") == target_id:
			return true
	return false


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
