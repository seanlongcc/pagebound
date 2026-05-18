extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")

const WEAPON_STAR_STICKER_SWARM := &"star_sticker_swarm"
const WEAPON_WAXLIGHT_COMET := &"waxlight_comet"
const PASSIVE_IDS := [
	&"candle_spark",
	&"cloud_seed",
	&"dream_thread",
	&"ribbon_spool",
	&"moon_button",
]
const OVERFLOW_IDS := [
	&"overflow_damage_crumb",
	&"overflow_range_crumb",
	&"overflow_size_crumb",
	&"overflow_cadence_crumb",
	&"overflow_duration_crumb",
]


func _initialize() -> void:
	var failures: Array[String] = []
	var state = RunUpgradeStateScript.new()
	state.configure(PrototypeContentFactoryScript.new())

	_exhaust_normal_choices(state)
	var eligible: Array[Dictionary] = state.debug_eligible_choices_for_level(99)
	for choice_id in OVERFLOW_IDS:
		_assert_true(_contains_choice_id(eligible, choice_id), "exhausted draft pool must expose %s" % String(choice_id), failures)
	_assert_true(_only_overflow_choices(eligible), "overflow must appear only after all normal weapon/item cards are exhausted", failures)

	var damage_before := state.damage_for_tags(&"overflow_smoke", 100.0, [])
	var range_before := state.range_multiplier()
	var size_before := state.size_multiplier()
	var cadence_before := state.cadence_multiplier()
	var duration_before := state.duration_multiplier()

	var damage_event: Dictionary = state.apply_choice(&"overflow_damage_crumb")
	state.apply_choice(&"overflow_damage_crumb")
	state.apply_choice(&"overflow_range_crumb")
	state.apply_choice(&"overflow_size_crumb")
	state.apply_choice(&"overflow_cadence_crumb")
	state.apply_choice(&"overflow_duration_crumb")

	_assert_true(not damage_event.is_empty(), "overflow damage crumb must apply and emit an event payload", failures)
	_assert_float_close(state.damage_for_tags(&"overflow_smoke", 100.0, []) - damage_before, 10.0, "repeat overflow damage crumbs must stack additively", failures)
	_assert_float_close(state.range_multiplier() - range_before, 0.05, "overflow range crumb must add +5% global range", failures)
	_assert_float_close(state.size_multiplier() - size_before, 0.05, "overflow size crumb must add +5% global size", failures)
	_assert_float_close(state.cadence_multiplier() - cadence_before, 0.05, "overflow cadence crumb must add +5% global cadence", failures)
	_assert_float_close(state.duration_multiplier() - duration_before, 0.05, "overflow duration crumb must add +5% global duration", failures)

	_finish(failures)


func _exhaust_normal_choices(state) -> void:
	state.apply_choice(&"new_weapon_waxlight_comet")
	for passive_id in PASSIVE_IDS:
		state.apply_choice(StringName("new_passive_%s" % String(passive_id)))
	for _upgrade in 9:
		state.apply_choice(StringName("weapon_upgrade_%s" % String(WEAPON_STAR_STICKER_SWARM)))
		state.apply_choice(StringName("weapon_upgrade_%s" % String(WEAPON_WAXLIGHT_COMET)))
	for _upgrade in 4:
		for passive_id in PASSIVE_IDS:
			state.apply_choice(StringName("passive_upgrade_%s" % String(passive_id)))


func _contains_choice_id(choices: Array[Dictionary], choice_id: StringName) -> bool:
	for choice in choices:
		if choice.get("id", &"") == choice_id:
			return true
	return false


func _only_overflow_choices(choices: Array[Dictionary]) -> bool:
	if choices.is_empty():
		return false
	for choice in choices:
		if choice.get("choice_type", &"") != &"overflow":
			return false
	return true


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _assert_float_close(actual: float, expected: float, message: String, failures: Array[String]) -> void:
	if absf(actual - expected) > 0.001:
		failures.append("%s (expected %.3f, got %.3f)" % [message, expected, actual])


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("overflow crumb smoke check passed")
		quit(0)
		return

	push_error("overflow crumb smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
