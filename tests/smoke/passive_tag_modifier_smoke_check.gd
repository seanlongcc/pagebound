extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var state = RunUpgradeStateScript.new()
	state.configure(PrototypeContentFactoryScript.new())

	_assert_true(state.has_method("damage_for_tags"), "upgrade state must expose global damage modifier", failures)
	if state.has_method("damage_for_tags"):
		_assert_true(is_equal_approx(state.damage_for_tags(&"firelight_debug", 10.0, [&"firelight"]), 10.0), "Candle Spark must not affect tagged damage before passive is owned", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"star_debug", 10.0, [&"star"]), 10.0), "Candle Spark must not affect Star damage before passive is owned", failures)
		_assert_true(is_equal_approx(state.weapon_damage(&"star_sticker_swarm", 100.0), 100.0), "Candle Spark must not affect Star Sticker Swarm before passive is owned", failures)

	var new_passive_event: Dictionary = state.apply_choice(&"new_passive_candle_spark")
	_assert_true(not new_passive_event.is_empty(), "Candle Spark acquisition must apply", failures)

	if state.has_method("damage_for_tags"):
		_assert_true(is_equal_approx(state.damage_for_tags(&"firelight_debug", 10.0, [&"firelight"]), 11.0), "Candle Spark L1 must add +10% Firelight damage", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"light_debug", 10.0, [&"light"]), 11.0), "Candle Spark L1 must add +10% Light damage", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"waxlight_debug", 10.0, [&"waxlight"]), 11.0), "Candle Spark L1 must add +10% Waxlight damage because passive stats are global", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"dreamlight_debug", 10.0, [&"dreamlight"]), 11.0), "Candle Spark L1 must add +10% unrelated damage because passive stats are global", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"star_debug", 10.0, [&"star"]), 11.0), "Candle Spark L1 must add +10% Star damage because catalyst tags do not limit passive stats", failures)
		_assert_true(is_equal_approx(state.weapon_damage(&"star_sticker_swarm", 100.0), 110.0), "Candle Spark L1 must boost Star Sticker Swarm damage globally", failures)

	for id in [&"cloud_seed", &"dream_thread", &"ribbon_spool", &"moon_button"]:
		_assert_true(not state.apply_choice(StringName("new_passive_%s" % String(id))).is_empty(), "%s acquisition must apply" % id, failures)

	_assert_true(is_equal_approx(state.size_multiplier(), 1.1), "Cloud Seed L1 must apply +10% size", failures)
	_assert_true(is_equal_approx(state.duration_multiplier(), 1.1), "Dream Thread L1 must apply +10% duration", failures)
	_assert_true(is_equal_approx(state.range_multiplier(), 1.1), "Ribbon Spool L1 must apply +10% range", failures)
	_assert_true(is_equal_approx(state.cadence_multiplier(), 1.1), "Moon Button L1 must apply +10% cadence", failures)

	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("passive tag modifier smoke check passed")
		quit(0)
		return

	push_error("passive tag modifier smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
