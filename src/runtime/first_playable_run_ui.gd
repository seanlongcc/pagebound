class_name FirstPlayableRunUi
extends RefCounted

var _hud: Control
var _hud_label: Label


## Ensures the first-playable HUD label exists under the supplied HUD root.
func ensure_hud(hud: Control) -> void:
	_hud = hud
	if _hud == null:
		return
	_hud.visible = true
	_hud_label = _hud.get_node_or_null("FirstPlayableHudLabel") as Label
	if _hud_label != null:
		return
	_hud_label = Label.new()
	_hud_label.name = "FirstPlayableHudLabel"
	_hud_label.position = Vector2(16.0, 12.0)
	_hud_label.custom_minimum_size = Vector2(520.0, 300.0)
	_hud_label.add_theme_font_size_override("font_size", 16)
	_hud_label.add_theme_color_override("font_color", Color(0.04, 0.035, 0.03, 1.0))
	_hud_label.add_theme_color_override("font_outline_color", Color(1.0, 0.96, 0.86, 0.85))
	_hud_label.add_theme_constant_override("outline_size", 3)
	_hud.add_child(_hud_label)


## Shows or hides the HUD root if it has been configured.
func set_hud_visible(visible: bool) -> void:
	if _hud != null:
		_hud.visible = visible


## Updates the HUD label from runtime-provided display context.
func update_hud(context: Dictionary) -> void:
	if _hud_label == null:
		return
	_hud_label.text = hud_text(context)


## Builds first-playable HUD text from primitive display values.
func hud_text(context: Dictionary) -> String:
	return "HP: %d/%d\nLevel: %d\nXP: %d/%d\nTime: %s\nWaxlight damage: %.1f\nWaxlight cooldown: %.2fs\nWaxlight duration: %.1fs\nWax cap: %d\nWax inactive/active: %d/%d\nDirector: %.2f/s %s\nBudget: %d\nSpawned: %d\nEnemies: %d active / Safety %d\n%s\nWeapons: %s\nPassives: %s" % [
		roundi(float(context.get("player_health", 0.0))),
		roundi(float(context.get("player_max_health", 0.0))),
		int(context.get("run_level", 0)),
		int(context.get("current_level_xp", 0)),
		int(context.get("xp_threshold", 0)),
		format_run_time(float(context.get("run_time_seconds", 0.0))),
		float(context.get("waxlight_damage", 0.0)),
		float(context.get("waxlight_cooldown_seconds", 0.0)),
		float(context.get("waxlight_duration_seconds", 0.0)),
		int(context.get("waxlight_cap", 0)),
		int(context.get("waxlight_unactivated_count", 0)),
		int(context.get("waxlight_active_count", 0)),
		float(context.get("director_spawn_rate", 0.0)),
		String(context.get("director_band", &"idle")),
		int(context.get("enemy_budget", 0)),
		int(context.get("spawned_count", 0)),
		int(context.get("active_enemy_count", 0)),
		int(context.get("safety_enemy_cap", 0)),
		String(context.get("page_event_line", "Event: none")),
		", ".join(weapon_display_names(context.get("weapon_ids", []))),
		", ".join(passive_display_names(context.get("passive_ids", []))),
	]


## Builds the fixed vertical-slice victory summary lines.
func summary_lines(context: Dictionary) -> Array[String]:
	return [
		"Victory",
		"Time Survived: %s" % format_run_time(float(context.get("run_time_seconds", 0.0))),
		"Level: %d" % int(context.get("run_level", 0)),
		"XP Collected: %d" % int(context.get("xp_total", 0)),
		"Enemies Defeated: %d" % int(context.get("enemies_defeated", 0)),
		"Weapons: %s" % ", ".join(weapon_display_names(context.get("weapon_ids", []))),
		"Passives: %s" % ", ".join(passive_display_names(context.get("passive_ids", []))),
	]


## Formats elapsed run time as mm:ss.
func format_run_time(total_seconds: float) -> String:
	var whole_seconds := maxi(0, floori(total_seconds))
	var minutes := whole_seconds / 60
	var seconds := whole_seconds % 60
	return "%02d:%02d" % [minutes, seconds]


## Converts owned weapon IDs to player-facing prototype names.
func weapon_display_names(weapon_ids: Array) -> Array[String]:
	var names: Array[String] = []
	for weapon_id in weapon_ids:
		match weapon_id:
			&"waxlight_comet":
				names.append("Waxlight Comet")
			&"star_sticker_swarm":
				names.append("Star Sticker Swarm")
			&"dreamsap_glob":
				names.append("Dreamsap Glob")
			&"color_bloom":
				names.append("Color Bloom")
			_:
				names.append(String(weapon_id).capitalize())
	return names


## Converts owned passive IDs to player-facing prototype names.
func passive_display_names(passive_ids: Array) -> Array[String]:
	var names: Array[String] = []
	for passive_id in passive_ids:
		match passive_id:
			&"candle_spark":
				names.append("Candle Spark")
			_:
				names.append(String(passive_id).capitalize())
	if names.is_empty():
		names.append("none")
	return names
