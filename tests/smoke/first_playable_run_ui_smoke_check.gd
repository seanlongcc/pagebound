extends SceneTree

const RunUiScript := preload("res://src/runtime/first_playable_run_ui.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var helper = RunUiScript.new()
	var hud := Control.new()
	helper.ensure_hud(hud)

	var label := hud.get_node_or_null("FirstPlayableHudLabel") as Label
	_assert_true(label != null, "HUD helper must create first playable HUD label", failures)

	var context := {
		"player_health": 42.0,
		"player_max_health": 50.0,
		"run_level": 2,
		"current_level_xp": 1,
		"xp_threshold": 6,
		"run_time_seconds": 125.0,
		"waxlight_damage": 14.5,
		"waxlight_cooldown_seconds": 0.75,
		"waxlight_duration_seconds": 2.5,
		"waxlight_cap": 5,
		"waxlight_unactivated_count": 2,
		"waxlight_active_count": 1,
		"director_spawn_rate": 1.2,
		"director_band": &"test_band",
		"enemy_budget": 9,
		"spawned_count": 12,
		"active_enemy_count": 4,
		"safety_enemy_cap": 16,
		"page_event_line": "Event: Fill the Color Well (Active) 2/5",
		"weapon_ids": [&"waxlight_comet", &"star_sticker_swarm"],
		"passive_ids": [&"candle_spark"],
		"xp_total": 7,
		"enemies_defeated": 3,
	}

	helper.update_hud(context)
	if label != null:
		_assert_true(label.text.contains("HP: 42/50"), "HUD text must show rounded HP", failures)
		_assert_true(label.text.contains("Time: 02:05"), "HUD text must format run time", failures)
		_assert_true(label.text.contains("Event: Fill the Color Well"), "HUD text must include Page Event line", failures)
		_assert_true(label.text.contains("Waxlight Comet, Star Sticker Swarm"), "HUD text must include weapon display names", failures)
		_assert_true(label.text.contains("Candle Spark"), "HUD text must include passive display names", failures)

	var summary_lines: Array[String] = helper.summary_lines(context)
	_assert_true(summary_lines.size() == 7, "summary helper must produce fixed victory summary lines", failures)
	if summary_lines.size() == 7:
		_assert_true(summary_lines[0] == "Victory", "summary must start with Victory", failures)
		_assert_true(summary_lines[1] == "Time Survived: 02:05", "summary must format survived time", failures)
		_assert_true(summary_lines[4] == "Enemies Defeated: 3", "summary must include defeated count", failures)
		_assert_true(summary_lines[5] == "Weapons: Waxlight Comet, Star Sticker Swarm", "summary must include weapon names", failures)
		_assert_true(summary_lines[6] == "Passives: Candle Spark", "summary must include passive names", failures)

	var no_passive_context := context.duplicate()
	no_passive_context["passive_ids"] = []
	_assert_true(helper.summary_lines(no_passive_context)[6] == "Passives: none", "summary must show none when no passives owned", failures)

	hud.queue_free()
	_finish(failures)


func _assert_true(value: bool, message: String, failures: Array[String]) -> void:
	if not value:
		failures.append(message)


func _finish(failures: Array[String]) -> void:
	if failures.is_empty():
		print("first playable run UI smoke check passed")
		quit(0)
		return

	push_error("first playable run UI smoke check failed:\n- " + "\n- ".join(failures))
	quit(1)
