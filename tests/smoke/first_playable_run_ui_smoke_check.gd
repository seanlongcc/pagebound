extends SceneTree

const RunUiScript := preload("res://src/runtime/first_playable_run_ui.gd")


func _initialize() -> void:
	var failures: Array[String] = []
	var helper = RunUiScript.new()
	var hud := Control.new()
	helper.ensure_hud(hud)

	var label := hud.get_node_or_null("FirstPlayableHudLabel") as Label
	_assert_true(hud.get_node_or_null("PartyReserve") != null, "HUD must reserve top-left party space", failures)
	_assert_true(hud.get_node_or_null("TopRightBanner") != null, "HUD must create exclusive top-right banner", failures)
	_assert_true(hud.get_node_or_null("BottomXPBar") != null, "HUD must create full-width bottom XP bar", failures)
	_assert_true(hud.get_node_or_null("LevelBadge") != null, "HUD must create bottom-left level badge", failures)
	_assert_true(hud.get_node_or_null("PetBadge") != null, "HUD must create Dog pet badge", failures)
	_assert_true(hud.get_node_or_null("LoadoutBook") != null, "HUD must create loadout slots", failures)
	_assert_true(hud.get_node_or_null("HPChip") != null, "HUD must create readable HP chip", failures)

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
		"page_event_state": {
			"id": &"fill_color_well",
			"active": true,
			"progress_percent": 75,
			"progress": 11,
			"required_progress": 15,
			"time_remaining_seconds": 42.0,
			"edge_marker_visible": true,
		},
		"boss_state": {
			"id": &"crownless_echo",
			"active": true,
			"queued_for_event": false,
			"defeated": false,
			"hp_percent": 72,
		},
		"weapon_ids": [&"waxlight_comet", &"star_sticker_swarm"],
		"passive_ids": [&"candle_spark"],
		"dog_tier": 1,
		"dog_feedback_text": "Dog fetch +2 XP",
		"xp_total": 7,
		"enemies_defeated": 3,
	}

	helper.update_hud(context)
	var hud_text := _visible_text(hud)
	_assert_true(hud_text.contains("HP 42/50"), "HUD must show rounded HP in readable chip", failures)
	_assert_true(hud_text.contains("Level") and hud_text.contains("2"), "HUD must show run level near bottom-left", failures)
	_assert_true(hud_text.contains("XP 17%"), "HUD must show XP percentage on bottom bar", failures)
	_assert_true(hud_text.contains("Fill the Color Well"), "HUD must show active Page Event banner", failures)
	_assert_true(hud_text.contains("75%"), "event banner must show percent as primary progress", failures)
	_assert_true(not hud_text.contains("Crownless Echo"), "event banner must be exclusive over boss banner", failures)
	_assert_true(hud_text.contains("Dog fetch +2 XP"), "HUD must show Dog pet feedback", failures)
	_assert_true(hud_text.contains("Waxlight Comet") and hud_text.contains("Candle Spark"), "HUD must include loadout names", failures)
	_assert_true(_named_children(hud.get_node_or_null("LoadoutBook/WeaponSlots")).size() == 5, "HUD must show 5 weapon slots", failures)
	_assert_true(_named_children(hud.get_node_or_null("LoadoutBook/ItemSlots")).size() == 5, "HUD must show 5 item slots", failures)
	_assert_true(not hud_text.contains("Wpn") and not hud_text.contains("Item Slots"), "HUD must not label rows with text category names", failures)
	_assert_true(not hud_text.contains("Director") and not hud_text.contains("Waxlight damage"), "HUD must not show debug stat text in player HUD", failures)

	var boss_context := context.duplicate(true)
	boss_context["page_event_state"] = {"id": &"", "active": false}
	helper.update_hud(boss_context)
	hud_text = _visible_text(hud)
	_assert_true(hud_text.contains("Crownless Echo"), "boss banner must take over when no event is active", failures)
	_assert_true(hud_text.contains("72%"), "boss banner must show HP percent as primary progress", failures)

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


func _named_children(node: Node) -> Array[Node]:
	var result: Array[Node] = []
	if node == null:
		return result
	for child in node.get_children():
		if child is Control:
			result.append(child)
	return result


func _visible_text(node: Node) -> String:
	if node == null:
		return ""
	if node is CanvasItem and not (node as CanvasItem).visible:
		return ""
	var text := ""
	if node is Label and node.visible:
		text += (node as Label).text + "\n"
	if node is Button and node.visible:
		text += (node as Button).text + "\n"
	for child in node.get_children():
		text += _visible_text(child)
	return text


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
