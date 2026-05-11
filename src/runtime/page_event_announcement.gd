class_name PageEventAnnouncement
extends Node

const DISPLAY_SECONDS := 3.0

var _hud: Control
var _root: Control
var _title_label: Label
var _descriptor_label: Label
var _remaining_seconds := 0.0


func _physics_process(delta: float) -> void:
	if _root == null or not _root.visible:
		return
	_remaining_seconds = maxf(0.0, _remaining_seconds - delta)
	if _remaining_seconds <= 0.0:
		_root.visible = false


func configure(hud: Control) -> void:
	_hud = hud
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_physics_process(true)
	_ensure_view()


func show_event(title: String, descriptor: String) -> void:
	_ensure_view()
	if _root == null:
		return
	_title_label.text = title
	_descriptor_label.text = descriptor
	_remaining_seconds = DISPLAY_SECONDS
	_root.visible = true


func is_showing() -> bool:
	return _root != null and _root.visible


func hide() -> void:
	_remaining_seconds = 0.0
	if _root != null:
		_root.visible = false


func _ensure_view() -> void:
	if _hud == null:
		return
	_root = _hud.get_node_or_null("PageEventAnnouncement") as Control
	if _root != null:
		_title_label = _root.get_node_or_null("AnnouncementStack/AnnouncementTitle") as Label
		_descriptor_label = _root.get_node_or_null("AnnouncementStack/AnnouncementDescriptor") as Label
		return

	_root = PanelContainer.new()
	_root.name = "PageEventAnnouncement"
	_root.visible = false
	_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_root.offset_left = 220.0
	_root.offset_top = 58.0
	_root.offset_right = -220.0
	_root.offset_bottom = 154.0
	_hud.add_child(_root)

	var stack := VBoxContainer.new()
	stack.name = "AnnouncementStack"
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 4)
	_root.add_child(stack)

	_title_label = Label.new()
	_title_label.name = "AnnouncementTitle"
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_title_label.add_theme_font_size_override("font_size", 26)
	_title_label.add_theme_color_override("font_color", Color(0.05, 0.035, 0.03, 1.0))
	_title_label.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.82, 0.9))
	_title_label.add_theme_constant_override("outline_size", 4)
	stack.add_child(_title_label)

	_descriptor_label = Label.new()
	_descriptor_label.name = "AnnouncementDescriptor"
	_descriptor_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_descriptor_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_descriptor_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_descriptor_label.add_theme_font_size_override("font_size", 16)
	_descriptor_label.add_theme_color_override("font_color", Color(0.05, 0.035, 0.03, 1.0))
	_descriptor_label.add_theme_color_override("font_outline_color", Color(1.0, 0.95, 0.82, 0.85))
	_descriptor_label.add_theme_constant_override("outline_size", 3)
	stack.add_child(_descriptor_label)
