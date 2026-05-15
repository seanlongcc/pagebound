class_name RunMenuController
extends Node

signal start_requested
signal retry_requested
signal main_menu_requested
signal pause_requested
signal resume_requested

var _modal_layer: Control
var _start_screen: Control
var _death_screen: Control
var _summary_screen: Control
var _pause_screen: Control
var _summary_label: Label
var _pause_label: Label


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)


func configure(modal_layer: Control) -> void:
	_modal_layer = modal_layer
	_set_always_process(_modal_layer)
	_ensure_start_screen()
	_ensure_death_screen()
	_ensure_summary_screen()
	_ensure_pause_screen()


func show_start_menu() -> void:
	_show_only(_start_screen)
	_focus_first_button(_start_screen)


func hide_all() -> void:
	if _modal_layer != null:
		_modal_layer.visible = false
	if _start_screen != null:
		_start_screen.visible = false
	if _death_screen != null:
		_death_screen.visible = false
	if _summary_screen != null:
		_summary_screen.visible = false
	if _pause_screen != null:
		_pause_screen.visible = false


func show_death_menu() -> void:
	_show_only(_death_screen)
	_focus_first_button(_death_screen)


func show_summary(summary_lines: Array[String]) -> void:
	_show_only(_summary_screen)
	if _summary_label != null:
		_summary_label.text = "\n".join(summary_lines)
	_focus_first_button(_summary_screen)


func show_pause(summary_lines: Array[String]) -> void:
	_show_only(_pause_screen)
	if _pause_label != null:
		_pause_label.text = "\n".join(summary_lines)
	_focus_first_button(_pause_screen)


func start_screen_visible() -> bool:
	return _start_screen != null and _start_screen.visible


func death_screen_visible() -> bool:
	return _death_screen != null and _death_screen.visible


func summary_screen_visible() -> bool:
	return _summary_screen != null and _summary_screen.visible


func pause_screen_visible() -> bool:
	return _pause_screen != null and _pause_screen.visible


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if pause_screen_visible():
			resume_requested.emit()
		else:
			pause_requested.emit()
		get_viewport().set_input_as_handled()
		return
	if start_screen_visible() and event.is_action_pressed("ui_accept"):
		start_requested.emit()
		get_viewport().set_input_as_handled()


func _ensure_start_screen() -> void:
	if _modal_layer == null:
		return
	_start_screen = _modal_layer.get_node_or_null("StartScreen") as Control
	if _start_screen != null:
		return
	_start_screen = _screen("StartScreen")
	_modal_layer.add_child(_start_screen)
	_start_screen.add_child(_title_label("StartTitle", "Pagebound", Vector2(320.0, 150.0), 42))
	var start_button := _button("StartButton", "Start Run", Vector2(340.0, 240.0))
	start_button.pressed.connect(func() -> void:
		start_requested.emit()
	)
	_start_screen.add_child(start_button)


func _ensure_death_screen() -> void:
	if _modal_layer == null:
		return
	_death_screen = _modal_layer.get_node_or_null("DeathScreen") as Control
	if _death_screen != null:
		return
	_death_screen = _screen("DeathScreen")
	_modal_layer.add_child(_death_screen)
	_death_screen.add_child(_title_label("DeathLabel", "Run Over", Vector2(320.0, 150.0), 36))
	var retry_button := _button("RetryButton", "Retry", Vector2(340.0, 235.0))
	retry_button.pressed.connect(func() -> void:
		retry_requested.emit()
	)
	_death_screen.add_child(retry_button)
	var menu_button := _button("MainMenuButton", "Main Menu", Vector2(340.0, 300.0))
	menu_button.pressed.connect(func() -> void:
		main_menu_requested.emit()
	)
	_death_screen.add_child(menu_button)


func _ensure_summary_screen() -> void:
	if _modal_layer == null:
		return
	_summary_screen = _modal_layer.get_node_or_null("VictoryScreen") as Control
	if _summary_screen == null:
		_summary_screen = _screen("VictoryScreen")
		_modal_layer.add_child(_summary_screen)
	_summary_screen.visible = false
	_summary_label = _summary_screen.get_node_or_null("SummaryLabel") as Label
	if _summary_label == null:
		_summary_label = _title_label("SummaryLabel", "", Vector2(280.0, 120.0), 24)
		_summary_label.custom_minimum_size = Vector2(520.0, 260.0)
		_summary_screen.add_child(_summary_label)
	if _summary_screen.get_node_or_null("RetryButton") == null:
		var retry_button := _button("RetryButton", "Retry", Vector2(300.0, 410.0))
		retry_button.pressed.connect(func() -> void:
			retry_requested.emit()
		)
		_summary_screen.add_child(retry_button)
	if _summary_screen.get_node_or_null("MainMenuButton") == null:
		var menu_button := _button("MainMenuButton", "Main Menu", Vector2(470.0, 410.0))
		menu_button.pressed.connect(func() -> void:
			main_menu_requested.emit()
		)
		_summary_screen.add_child(menu_button)


func _ensure_pause_screen() -> void:
	if _modal_layer == null:
		return
	_pause_screen = _modal_layer.get_node_or_null("PauseScreen") as Control
	if _pause_screen == null:
		_pause_screen = _screen("PauseScreen")
		_modal_layer.add_child(_pause_screen)
	_pause_screen.visible = false
	_pause_label = _pause_screen.get_node_or_null("PauseSummaryLabel") as Label
	if _pause_label == null:
		_pause_label = _title_label("PauseSummaryLabel", "", Vector2(260.0, 100.0), 21)
		_pause_label.custom_minimum_size = Vector2(620.0, 260.0)
		_pause_screen.add_child(_pause_label)
	if _pause_screen.get_node_or_null("ResumeButton") == null:
		var resume_button := _button("ResumeButton", "Resume", Vector2(280.0, 410.0))
		resume_button.pressed.connect(func() -> void:
			resume_requested.emit()
		)
		_pause_screen.add_child(resume_button)
	if _pause_screen.get_node_or_null("OptionsButton") == null:
		var options_button := _button("OptionsButton", "Options", Vector2(450.0, 410.0))
		_pause_screen.add_child(options_button)
	if _pause_screen.get_node_or_null("QuitButton") == null:
		var quit_button := _button("QuitButton", "Quit", Vector2(620.0, 410.0))
		quit_button.pressed.connect(func() -> void:
			main_menu_requested.emit()
		)
		_pause_screen.add_child(quit_button)


func _screen(screen_name: String) -> Control:
	var screen := Control.new()
	screen.name = screen_name
	screen.visible = false
	screen.process_mode = Node.PROCESS_MODE_ALWAYS
	screen.layout_mode = 1
	screen.set_anchors_preset(Control.PRESET_FULL_RECT)
	return screen


func _title_label(label_name: String, text: String, position: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.name = label_name
	label.text = text
	label.position = position
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.05, 0.035, 0.03, 1.0))
	label.add_theme_color_override("font_outline_color", Color(1.0, 0.9, 0.78, 0.92))
	label.add_theme_constant_override("outline_size", 4)
	return label


func _button(button_name: String, text: String, position: Vector2) -> Button:
	var button := Button.new()
	button.name = button_name
	button.text = text
	button.position = position
	button.custom_minimum_size = Vector2(150.0, 48.0)
	button.focus_mode = Control.FOCUS_ALL
	button.process_mode = Node.PROCESS_MODE_ALWAYS
	return button


func _show_only(screen: Control) -> void:
	if _modal_layer != null:
		_modal_layer.visible = true
	for candidate in [_start_screen, _death_screen, _summary_screen, _pause_screen]:
		if candidate != null:
			candidate.visible = candidate == screen


func _focus_first_button(screen: Control) -> void:
	if screen == null:
		return
	for child in screen.get_children():
		if child is Button:
			(child as Button).grab_focus()
			return


func _set_always_process(node: Node) -> void:
	if node == null:
		return
	node.process_mode = Node.PROCESS_MODE_ALWAYS
