class_name RunPauseSummaryBuilder
extends RefCounted


static func lines(context: Dictionary) -> Array[String]:
	var run_ui = context.get("run_ui", null)
	return [
		"Paused",
		"Time: %s" % _format_time(run_ui, float(context.get("run_time_seconds", 0.0))),
		"Level: %d  XP: %d/%d" % [int(context.get("run_level", 1)), int(context.get("current_level_xp", 0)), int(context.get("xp_threshold", 1))],
		"HP: %d/%d" % [roundi(float(context.get("player_health", 0.0))), roundi(float(context.get("player_max_health", 0.0)))],
		"Weapons: %s" % _weapon_level_names(context),
		"Items: %s" % _level_names(context.get("passive_ids", []), context.get("passive_levels", {}), context.get("content_factory", null), false),
	]


static func _format_time(run_ui, seconds: float) -> String:
	if run_ui != null and run_ui.has_method("format_run_time"):
		return run_ui.format_run_time(seconds)
	var whole_seconds := maxi(0, floori(seconds))
	return "%02d:%02d" % [whole_seconds / 60, whole_seconds % 60]


static func _level_names(ids: Array, levels: Dictionary, content_factory, is_weapon: bool) -> String:
	var parts: Array[String] = []
	for id in ids:
		parts.append("%s Lv%d" % [_content_display_name(id, content_factory, is_weapon), int(levels.get(id, 1))])
	if parts.is_empty():
		return "none"
	return ", ".join(parts)


static func _weapon_level_names(context: Dictionary) -> String:
	var ids: Array = context.get("weapon_ids", [])
	var levels: Dictionary = context.get("weapon_levels", {})
	var applied_by_weapon: Dictionary = context.get("weapon_applied_upgrades", {})
	var content_factory = context.get("content_factory", null)
	var parts: Array[String] = []
	for id in ids:
		var applied: Array = applied_by_weapon.get(id, [])
		var applied_text := "none" if applied.is_empty() else ", ".join(_string_array(applied))
		parts.append("%s Lv%d Applied Upgrades: %s" % [_content_display_name(id, content_factory, true), int(levels.get(id, 1)), applied_text])
	if parts.is_empty():
		return "none"
	return " | ".join(parts)


static func _string_array(values: Array) -> Array[String]:
	var result: Array[String] = []
	for value in values:
		result.append(String(value))
	return result


static func _content_display_name(content_id: StringName, content_factory, is_weapon: bool) -> String:
	if content_factory != null:
		var resource = content_factory.weapon_for_id(content_id) if is_weapon else content_factory.passive_for_id(content_id)
		if resource != null and "display_name" in resource:
			return resource.display_name
	return String(content_id).replace("_", " ").capitalize()
