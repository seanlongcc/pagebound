extends SceneTree

const PrototypeContentFactoryScript := preload("res://src/data/prototype_content_factory.gd")
const RunUpgradeStateScript := preload("res://src/runtime/run_upgrade_state.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var factory = PrototypeContentFactoryScript.new()
	var weapon_ids: Array[StringName] = []
	for weapon in factory.weapon_pool():
		if weapon != null:
			weapon_ids.append(weapon.id)
	_assert_true(weapon_ids.has(&"waxlight_comet"), "weapon pool must include Waxlight Comet", failures)
	_assert_true(weapon_ids.has(&"star_sticker_swarm"), "weapon pool must include Star Sticker Swarm", failures)

	var star = factory.weapon_for_id(&"star_sticker_swarm")
	_assert_true(star != null, "Star Sticker Swarm data must load by ID", failures)
	if star != null:
		_assert_true(star.catalyst_tags == [&"star", &"moon"], "Star Sticker Swarm catalyst tags must be Star/Moon", failures)
		_assert_true(star.weapon_type_id == &"orbit_attach", "Star Sticker Swarm must use orbit/attach behavior ID", failures)
		_assert_true(star.has_valid_base_stats(), "Star Sticker Swarm must have valid editable base stats", failures)

	var expected_passives := {
		&"candle_spark": {"rarity": &"common", "stat": &"damage", "tags": [&"firelight", &"light"]},
		&"cloud_seed": {"rarity": &"common", "stat": &"size", "tags": [&"bloom", &"wonder"]},
		&"dream_thread": {"rarity": &"common", "stat": &"duration", "tags": [&"dream", &"thread"]},
		&"ribbon_spool": {"rarity": &"common", "stat": &"range", "tags": [&"thread", &"star"]},
		&"moon_button": {"rarity": &"common", "stat": &"cadence", "tags": [&"moon", &"echo"]},
	}
	for passive_id in expected_passives.keys():
		var passive = factory.passive_for_id(passive_id)
		_assert_true(passive != null, "%s passive data must load by ID" % passive_id, failures)
		if passive == null:
			continue
		var expected: Dictionary = expected_passives[passive_id]
		_assert_true(passive.draft_rarity == expected["rarity"], "%s must be Common rarity" % passive_id, failures)
		_assert_true(passive.stat_id == expected["stat"], "%s must use documented stat channel" % passive_id, failures)
		_assert_true(passive.catalyst_tags == expected["tags"], "%s must use documented catalyst tags" % passive_id, failures)
		_assert_true(passive.level_values == [0.1, 0.2, 0.3, 0.4, 0.5], "%s must use +10/+20/+30/+40/+50%% ladder" % passive_id, failures)

	for enemy in factory.all_enemy_families():
		_assert_true(enemy != null, "enemy data must load", failures)
		if enemy == null:
			continue
		_assert_true(is_equal_approx(enemy.contact_damage, 90.0), "%s contact damage must be 50%% above old 60 baseline" % enemy.id, failures)

	var state = RunUpgradeStateScript.new()
	state.configure(factory)
	var first_choices := state.prototype_choices_for_level(2)
	_assert_true(first_choices.size() == 3, "expanded draft must still show exactly 3 choices", failures)
	if state.has_method("debug_eligible_choices_for_level"):
		_assert_true(_choices_include_new_batch(state.debug_eligible_choices_for_level(2)), "expanded draft pool should be able to offer Waxlight or requested passives", failures)
	for choice in first_choices:
		var tags: Array = choice.get("tags", [])
		_assert_true(String(choice.get("title", "")) != "Waxlight Comet +1", "weapon upgrade card title must not be generic", failures)
		_assert_true(String(choice.get("icon_label", "")) != "", "draft choice must include icon metadata", failures)
		_assert_true(tags.size() > 0 or choice.get("choice_type", &"") == &"overflow", "draft choice must include tags when relevant", failures)
		_assert_true(String(choice.get("slot_line", "")) != "", "draft choice must include slot-fill metadata", failures)
		_assert_true(String(choice.get("compatibility_hint", "")) != "", "draft choice must include compatibility hint", failures)

	_finish(failures)


func _choices_include_new_batch(choices: Array[Dictionary]) -> bool:
	for choice in choices:
		if choice.get("weapon_id", &"") == &"waxlight_comet":
			return true
		if [&"candle_spark", &"cloud_seed", &"dream_thread", &"ribbon_spool", &"moon_button"].has(choice.get("passive_id", &"")):
			return true
	return false


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("second content batch smoke check passed")
		quit(0)
		return

	push_error("second content batch smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
