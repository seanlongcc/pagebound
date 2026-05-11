extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var state = RunUpgradeStateScript.new()
	state.configure(PrototypeContentFactoryScript.new())

	_assert_true(state.has_method("damage_for_tags"), "upgrade state must expose tag-based damage modifier", failures)
	if state.has_method("damage_for_tags"):
		_assert_true(is_equal_approx(state.damage_for_tags(&"waxlight_debug", 10.0, [&"waxlight"]), 10.0), "Candle Spark must not affect tagged damage before passive is owned", failures)

	var new_passive_event: Dictionary = state.apply_choice(&"new_passive_candle_spark")
	_assert_true(not new_passive_event.is_empty(), "Candle Spark acquisition must apply", failures)

	if state.has_method("damage_for_tags"):
		_assert_true(is_equal_approx(state.damage_for_tags(&"waxlight_debug", 10.0, [&"waxlight"]), 11.5), "Candle Spark must affect Waxlight-tagged damage", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"firelight_debug", 10.0, [&"firelight"]), 11.5), "Candle Spark must affect Firelight-tagged damage", failures)
		_assert_true(is_equal_approx(state.damage_for_tags(&"dreamlight_debug", 10.0, [&"dreamlight"]), 10.0), "Candle Spark must not affect unrelated damage tags", failures)

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
