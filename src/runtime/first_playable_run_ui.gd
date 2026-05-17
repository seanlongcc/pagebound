class_name FirstPlayableRunUi
extends RefCounted

const SLOT_COUNT := 5

var _hud: Control


## Ensures the first-polished HUD control tree exists under the supplied HUD root.
func ensure_hud(hud: Control) -> void:
	_hud = hud
	if _hud == null:
		return
	_hud.visible = true
	_hud.set_anchors_preset(Control.PRESET_FULL_RECT)
	_remove_old_debug_label()
	_ensure_party_reserve()
	_ensure_kill_counter()
	_ensure_run_timer()
	_ensure_top_right_banner()
	_ensure_event_marker()
	_ensure_hp_chip()
	_ensure_dash_meter()
	_ensure_loadout_book()
	_ensure_bottom_xp_bar()
	_ensure_level_badge()
	_ensure_pet_badge()


## Shows or hides the HUD root if it has been configured.
func set_hud_visible(visible: bool) -> void:
	if _hud != null:
		_hud.visible = visible


## Updates the HUD controls from runtime-provided display context.
func update_hud(context: Dictionary) -> void:
	if _hud == null:
		return
	_update_hp(context)
	_update_dash(context)
	_update_kill_counter(context)
	_update_run_timer(context)
	_update_banner(context)
	_update_event_marker(context)
	_update_xp(context)
	_update_level(context)
	_update_pet(context)
	_update_loadout(context)


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
			&"cloud_seed":
				names.append("Cloud Seed")
			&"dream_thread":
				names.append("Dream Thread")
			&"ribbon_spool":
				names.append("Ribbon Spool")
			&"moon_button":
				names.append("Moon Button")
			_:
				names.append(String(passive_id).capitalize())
	if names.is_empty():
		names.append("none")
	return names


func _remove_old_debug_label() -> void:
	var old_label := _hud.get_node_or_null("FirstPlayableHudLabel")
	if old_label != null:
		_hud.remove_child(old_label)
		old_label.queue_free()


func _ensure_party_reserve() -> void:
	var row := _hud.get_node_or_null("PartyReserve") as CanvasItem
	if row != null:
		row.visible = false


func _ensure_kill_counter() -> void:
	if _hud.get_node_or_null("KillCounter") != null:
		return
	var counter := Label.new()
	counter.name = "KillCounter"
	counter.set_anchors_preset(Control.PRESET_TOP_LEFT)
	counter.offset_left = 24.0
	counter.offset_top = 20.0
	counter.offset_right = 150.0
	counter.offset_bottom = 54.0
	counter.add_theme_font_size_override("font_size", 20)
	counter.add_theme_color_override("font_color", Color(0.05, 0.035, 0.02, 1.0))
	counter.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.76, 0.9))
	counter.add_theme_constant_override("outline_size", 2)
	_hud.add_child(counter)


func _ensure_run_timer() -> void:
	if _hud.get_node_or_null("RunTimer") != null:
		return
	var timer := Label.new()
	timer.name = "RunTimer"
	timer.set_anchors_preset(Control.PRESET_TOP_WIDE)
	timer.offset_left = 0.0
	timer.offset_top = 16.0
	timer.offset_right = 0.0
	timer.offset_bottom = 56.0
	timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	timer.add_theme_font_size_override("font_size", 28)
	timer.add_theme_color_override("font_color", Color(0.05, 0.035, 0.02, 1.0))
	timer.add_theme_color_override("font_outline_color", Color(1.0, 0.92, 0.76, 0.9))
	timer.add_theme_constant_override("outline_size", 3)
	_hud.add_child(timer)


func _ensure_event_marker() -> void:
	if _hud.get_node_or_null("PageEventEdgeMarker") != null:
		return
	var marker := Label.new()
	marker.name = "PageEventEdgeMarker"
	marker.set_anchors_preset(Control.PRESET_TOP_WIDE)
	marker.offset_left = 0.0
	marker.offset_top = 58.0
	marker.offset_right = 0.0
	marker.offset_bottom = 86.0
	marker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	marker.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	marker.add_theme_font_size_override("font_size", 18)
	marker.add_theme_color_override("font_color", Color(0.42, 0.02, 0.18, 1.0))
	marker.text = "Color Well ->"
	marker.visible = false
	_hud.add_child(marker)


func _ensure_top_right_banner() -> void:
	if _hud.get_node_or_null("TopRightBanner") != null:
		return
	var banner := PanelContainer.new()
	banner.name = "TopRightBanner"
	banner.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	banner.offset_left = -430.0
	banner.offset_top = 22.0
	banner.offset_right = -24.0
	banner.offset_bottom = 132.0
	banner.add_theme_stylebox_override("panel", _panel_style(Color(0.98, 0.92, 0.76, 0.92), Color(0.24, 0.16, 0.08, 0.9), 2))
	_hud.add_child(banner)
	var stack := VBoxContainer.new()
	stack.name = "BannerStack"
	stack.add_theme_constant_override("separation", 3)
	banner.add_child(stack)
	for name in ["BannerKicker", "BannerTitle", "BannerMetric", "BannerSubline"]:
		var label := Label.new()
		label.name = name
		label.add_theme_color_override("font_color", Color(0.08, 0.05, 0.03, 1.0))
		stack.add_child(label)
	(label("BannerTitle")).add_theme_font_size_override("font_size", 22)
	(label("BannerMetric")).add_theme_font_size_override("font_size", 30)
	var bar := ProgressBar.new()
	bar.name = "BannerProgress"
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.show_percentage = false
	stack.add_child(bar)


func _ensure_hp_chip() -> void:
	if _hud.get_node_or_null("HPChip") != null:
		return
	var chip := PanelContainer.new()
	chip.name = "HPChip"
	chip.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	chip.offset_left = 24.0
	chip.offset_top = -142.0
	chip.offset_right = 224.0
	chip.offset_bottom = -86.0
	chip.add_theme_stylebox_override("panel", _panel_style(Color(0.98, 0.93, 0.80, 0.9), Color(0.26, 0.11, 0.08, 0.9), 2))
	_hud.add_child(chip)
	var stack := VBoxContainer.new()
	chip.add_child(stack)
	var hp_label := Label.new()
	hp_label.name = "HPLabel"
	hp_label.add_theme_font_size_override("font_size", 17)
	hp_label.add_theme_color_override("font_color", Color(0.08, 0.04, 0.03, 1.0))
	stack.add_child(hp_label)
	var hp_bar := ProgressBar.new()
	hp_bar.name = "HPProgress"
	hp_bar.min_value = 0.0
	hp_bar.max_value = 100.0
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(176.0, 16.0)
	stack.add_child(hp_bar)


func _ensure_dash_meter() -> void:
	if _hud.get_node_or_null("DashMeter") != null:
		return
	var meter := PanelContainer.new()
	meter.name = "DashMeter"
	meter.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	meter.offset_left = 230.0
	meter.offset_top = -142.0
	meter.offset_right = 390.0
	meter.offset_bottom = -86.0
	meter.add_theme_stylebox_override("panel", _panel_style(Color(0.94, 0.97, 0.88, 0.9), Color(0.14, 0.24, 0.12, 0.9), 2))
	_hud.add_child(meter)
	var stack := VBoxContainer.new()
	meter.add_child(stack)
	var dash_label := Label.new()
	dash_label.name = "DashLabel"
	dash_label.add_theme_font_size_override("font_size", 16)
	dash_label.add_theme_color_override("font_color", Color(0.05, 0.07, 0.03, 1.0))
	stack.add_child(dash_label)
	var dash_bar := ProgressBar.new()
	dash_bar.name = "DashProgress"
	dash_bar.min_value = 0.0
	dash_bar.max_value = 100.0
	dash_bar.show_percentage = false
	dash_bar.custom_minimum_size = Vector2(136.0, 16.0)
	stack.add_child(dash_bar)


func _ensure_loadout_book() -> void:
	if _hud.get_node_or_null("LoadoutBook") != null:
		return
	var book := VBoxContainer.new()
	book.name = "LoadoutBook"
	book.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	book.offset_left = -560.0
	book.offset_top = -96.0
	book.offset_right = -24.0
	book.offset_bottom = -22.0
	book.add_theme_constant_override("separation", 5)
	_hud.add_child(book)
	_add_slot_row(book, "WeaponSlots")
	_add_slot_row(book, "ItemSlots")


func _ensure_bottom_xp_bar() -> void:
	if _hud.get_node_or_null("BottomXPBar") != null:
		return
	var root := Control.new()
	root.name = "BottomXPBar"
	root.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	root.offset_left = 0.0
	root.offset_top = -20.0
	root.offset_right = 0.0
	root.offset_bottom = 0.0
	_hud.add_child(root)
	var bar := ProgressBar.new()
	bar.name = "XPProgress"
	bar.set_anchors_preset(Control.PRESET_FULL_RECT)
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.show_percentage = false
	root.add_child(bar)
	var text := Label.new()
	text.name = "XPPercentLabel"
	text.set_anchors_preset(Control.PRESET_FULL_RECT)
	text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text.add_theme_font_size_override("font_size", 14)
	text.add_theme_color_override("font_color", Color(0.06, 0.04, 0.03, 1.0))
	root.add_child(text)


func _ensure_level_badge() -> void:
	if _hud.get_node_or_null("LevelBadge") != null:
		return
	var badge := Label.new()
	badge.name = "LevelBadge"
	badge.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	badge.offset_left = 24.0
	badge.offset_top = -72.0
	badge.offset_right = 118.0
	badge.offset_bottom = -28.0
	badge.add_theme_font_size_override("font_size", 18)
	badge.add_theme_color_override("font_color", Color(0.05, 0.035, 0.02, 1.0))
	_hud.add_child(badge)


func _ensure_pet_badge() -> void:
	if _hud.get_node_or_null("PetBadge") != null:
		if _hud.get_node_or_null("DogPetIcon") == null:
			_add_dog_icon()
		return
	var badge := Label.new()
	badge.name = "PetBadge"
	badge.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	badge.offset_left = 124.0
	badge.offset_top = -72.0
	badge.offset_right = 292.0
	badge.offset_bottom = -28.0
	badge.add_theme_font_size_override("font_size", 16)
	badge.add_theme_color_override("font_color", Color(0.05, 0.035, 0.02, 1.0))
	_hud.add_child(badge)
	_add_dog_icon()


func _add_dog_icon() -> void:
	var icon := Label.new()
	icon.name = "DogPetIcon"
	icon.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	icon.offset_left = 296.0
	icon.offset_top = -72.0
	icon.offset_right = 352.0
	icon.offset_bottom = -28.0
	icon.text = "Dog"
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 16)
	icon.add_theme_color_override("font_color", Color(0.18, 0.10, 0.04, 1.0))
	_hud.add_child(icon)


func _add_slot_row(parent: Node, row_name: String) -> void:
	var row := HBoxContainer.new()
	row.name = row_name
	row.add_theme_constant_override("separation", 5)
	parent.add_child(row)
	for index in SLOT_COUNT:
		var slot := Label.new()
		slot.name = "Slot%d" % (index + 1)
		slot.custom_minimum_size = Vector2(102.0, 32.0)
		slot.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		slot.add_theme_font_size_override("font_size", 12)
		slot.add_theme_color_override("font_color", Color(0.06, 0.045, 0.03, 1.0))
		slot.add_theme_stylebox_override("normal", _panel_style(Color(0.98, 0.94, 0.84, 0.92), Color(0.34, 0.22, 0.12, 0.75), 1))
		row.add_child(slot)


func _update_hp(context: Dictionary) -> void:
	var current := roundi(float(context.get("player_health", 0.0)))
	var max_value := maxi(1, roundi(float(context.get("player_max_health", 0.0))))
	(label("HPLabel")).text = "HP %d/%d" % [current, max_value]
	var bar := _hud.get_node_or_null("HPChip/HPProgress") as ProgressBar
	if bar != null:
		bar.value = clampf(float(current) / float(max_value) * 100.0, 0.0, 100.0)


func _update_dash(context: Dictionary) -> void:
	var percent := clampi(int(context.get("dash_recharge_percent", 100)), 0, 100)
	var dash_label := label("DashLabel")
	if dash_label != null:
		dash_label.text = "Dash %d%%" % percent
	var dash_bar := _find_named(_hud, "DashProgress") as ProgressBar
	if dash_bar != null:
		dash_bar.value = percent


func _update_kill_counter(context: Dictionary) -> void:
	var counter := _hud.get_node_or_null("KillCounter") as Label
	if counter != null:
		counter.text = "Kills %d" % int(context.get("enemies_defeated", 0))


func _update_run_timer(context: Dictionary) -> void:
	var timer := _hud.get_node_or_null("RunTimer") as Label
	if timer != null:
		timer.text = format_run_time(float(context.get("run_time_seconds", 0.0)))


func _update_banner(context: Dictionary) -> void:
	var event_state: Dictionary = context.get("page_event_state", {})
	var boss_state: Dictionary = context.get("boss_state", {})
	var banner := _hud.get_node_or_null("TopRightBanner") as Control
	if banner == null:
		return
	var show_event: bool = bool(event_state.get("active", false))
	var show_boss: bool = not show_event and boss_state.get("id", &"") != &"" and not bool(boss_state.get("defeated", false))
	banner.visible = show_event or show_boss
	if show_event:
		_set_banner("Page Event", "Fill the Color Well", "%d%%" % int(event_state.get("progress_percent", 0)), "%d/%d, %s" % [
			int(event_state.get("progress", 0)),
			int(event_state.get("required_progress", 0)),
			format_run_time(float(event_state.get("time_remaining_seconds", 0.0))),
		], float(event_state.get("progress_percent", 0)))
	elif show_boss:
		var metric := "Queued" if bool(boss_state.get("queued_for_event", false)) else "%d%%" % int(boss_state.get("hp_percent", 0))
		_set_banner("Crownless Echo", "The Scribble King Stirs", metric, "3:30", float(boss_state.get("hp_percent", 0)))


func _update_event_marker(context: Dictionary) -> void:
	var marker := _hud.get_node_or_null("PageEventEdgeMarker") as Label
	if marker == null:
		return
	var event_state: Dictionary = context.get("page_event_state", {})
	marker.visible = bool(event_state.get("edge_marker_visible", false))


func _set_banner(kicker: String, title: String, metric: String, subline: String, progress: float) -> void:
	(label("BannerKicker")).text = kicker
	(label("BannerTitle")).text = title
	(label("BannerMetric")).text = metric
	(label("BannerSubline")).text = subline
	var bar := _hud.get_node_or_null("TopRightBanner/BannerStack/BannerProgress") as ProgressBar
	if bar != null:
		bar.value = clampf(progress, 0.0, 100.0)


func _update_xp(context: Dictionary) -> void:
	var current := int(context.get("current_level_xp", 0))
	var threshold := maxi(1, int(context.get("xp_threshold", 1)))
	var percent := clampi(roundi(float(current) / float(threshold) * 100.0), 0, 100)
	var bar := _hud.get_node_or_null("BottomXPBar/XPProgress") as ProgressBar
	if bar != null:
		bar.value = percent
	var text := _hud.get_node_or_null("BottomXPBar/XPPercentLabel") as Label
	if text != null:
		text.text = "XP %d%%" % percent


func _update_level(context: Dictionary) -> void:
	(label("LevelBadge")).text = "Level %d" % int(context.get("run_level", 0))


func _update_pet(context: Dictionary) -> void:
	(label("PetBadge")).text = "Dog T%d: %s" % [
		int(context.get("dog_tier", 1)),
		String(context.get("dog_feedback_text", "Dog")),
	]
	var icon := _hud.get_node_or_null("DogPetIcon") as Label
	if icon != null:
		icon.scale = Vector2.ONE * (1.18 if String(context.get("dog_feedback_text", "Dog")) != "Dog" else 1.0)


func _update_loadout(context: Dictionary) -> void:
	_update_slot_row(_hud.get_node_or_null("LoadoutBook/WeaponSlots"), _names_with_levels(weapon_display_names(context.get("weapon_ids", [])), context.get("weapon_ids", []), context.get("weapon_levels", {})))
	_update_slot_row(_hud.get_node_or_null("LoadoutBook/ItemSlots"), _names_with_levels(passive_display_names(context.get("passive_ids", [])), context.get("passive_ids", []), context.get("passive_levels", {})))


func _update_slot_row(row: Node, names: Array[String]) -> void:
	if row == null:
		return
	var visible_names := names.duplicate()
	if visible_names.size() == 1 and visible_names[0] == "none":
		visible_names.clear()
	for index in SLOT_COUNT:
		var slot := row.get_node_or_null("Slot%d" % (index + 1)) as Label
		if slot == null:
			continue
		slot.text = visible_names[index] if index < visible_names.size() else "Empty"


func _names_with_levels(names: Array[String], ids: Array, levels: Dictionary) -> Array[String]:
	var result: Array[String] = []
	for index in names.size():
		if names[index] == "none":
			continue
		var id = ids[index] if index < ids.size() else &""
		result.append("%s Lv%d" % [names[index], int(levels.get(id, 1))])
	if result.is_empty():
		result.append("none")
	return result


func label(node_name: String) -> Label:
	return _find_named(_hud, node_name) as Label


func _find_named(node: Node, node_name: String) -> Node:
	if node == null:
		return null
	if node.name == node_name:
		return node
	for child in node.get_children():
		var found := _find_named(child, node_name)
		if found != null:
			return found
	return null


func _panel_style(bg_color: Color, border_color: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6
	style.content_margin_left = 8.0
	style.content_margin_top = 6.0
	style.content_margin_right = 8.0
	style.content_margin_bottom = 6.0
	return style
