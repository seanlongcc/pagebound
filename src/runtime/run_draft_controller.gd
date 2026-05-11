class_name RunDraftController
extends Node

const PROTOTYPE_CHOICES := [
	{
		"id": &"waxlight_damage_plus_1",
		"title": "Waxlight damage +1",
		"description": "Future Waxlight hits and dash activations hit harder.",
	},
	{
		"id": &"waxlight_cooldown_minus_10",
		"title": "Waxlight cooldown -10%",
		"description": "Waxlight Comet fires more often.",
	},
	{
		"id": &"player_max_hp_plus_10",
		"title": "Player max HP +10",
		"description": "Increase maximum HP and refill the new amount.",
	},
]

var _event_bus: Node
var _modal_layer: Control
var _level_up_screen: Control
var _choice_provider
var _choice_buttons: Array[Button] = []
var _current_choices: Array[Dictionary] = []
var _draft_open := false
var _focused_choice_index := 0
var _selected_choice_id: StringName = &""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_unhandled_input(true)


## Connects draft UI to runtime events and existing shell UI slots.
func configure(event_bus: Node, modal_layer: Control, level_up_screen: Control, choice_provider = null) -> void:
	_event_bus = event_bus
	_modal_layer = modal_layer
	_level_up_screen = level_up_screen
	_choice_provider = choice_provider
	process_mode = Node.PROCESS_MODE_ALWAYS
	_set_always_process(_modal_layer)
	_set_always_process(_level_up_screen)
	_ensure_ui()
	if _event_bus != null and _event_bus.has_signal("run_level_gained"):
		if not _event_bus.run_level_gained.is_connected(_on_run_level_gained):
			_event_bus.run_level_gained.connect(_on_run_level_gained)


## Returns true while a level-up draft is open.
func is_draft_open() -> bool:
	return _draft_open


## Returns current visible choice count.
func debug_choice_count() -> int:
	return _current_choices.size()


## Returns last selected choice ID.
func debug_selected_choice_id() -> StringName:
	return _selected_choice_id


## Accepts focused/default choice for smoke tests and keyboard/gamepad flow.
func accept_focused_choice() -> void:
	_select_choice_index(_focused_choice_index)


## Focuses a visible choice by index for keyboard/gamepad smoke flow.
func focus_choice_index(choice_index: int) -> void:
	if choice_index < 0 or choice_index >= _current_choices.size():
		return
	_focused_choice_index = choice_index
	if choice_index < _choice_buttons.size():
		_choice_buttons[choice_index].grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not _draft_open:
		return
	if event.is_action_pressed("ui_accept"):
		accept_focused_choice()
		get_viewport().set_input_as_handled()


func _on_run_level_gained(event: Dictionary) -> void:
	if _draft_open:
		return
	_open_draft(event)


func _open_draft(level_event: Dictionary) -> void:
	_current_choices = _prototype_choices()
	_focused_choice_index = 0
	_selected_choice_id = &""
	_sync_choice_buttons()
	if _modal_layer != null:
		_modal_layer.visible = true
	if _level_up_screen != null:
		_level_up_screen.visible = true
	if not _choice_buttons.is_empty():
		_choice_buttons[0].grab_focus()
	_draft_open = true
	if get_tree() != null:
		get_tree().paused = true
	_emit_draft_opened(level_event)


func _select_choice_index(choice_index: int) -> void:
	if not _draft_open or choice_index < 0 or choice_index >= _current_choices.size():
		return
	var choice := _current_choices[choice_index]
	_selected_choice_id = choice["id"]
	_emit_choice_selected(choice)
	_close_draft()


func _close_draft() -> void:
	_draft_open = false
	if _level_up_screen != null:
		_level_up_screen.visible = false
	if _modal_layer != null:
		_modal_layer.visible = false
	if get_tree() != null:
		get_tree().paused = false


func _ensure_ui() -> void:
	if _level_up_screen == null or _level_up_screen.get_node_or_null("DraftChoicePanel") != null:
		return
	var panel := VBoxContainer.new()
	panel.name = "DraftChoicePanel"
	panel.position = Vector2(320.0, 120.0)
	panel.custom_minimum_size = Vector2(520.0, 280.0)
	panel.add_theme_constant_override("separation", 10)
	_level_up_screen.add_child(panel)

	var title := Label.new()
	title.name = "DraftTitle"
	title.text = "Level Up"
	title.add_theme_font_size_override("font_size", 28)
	panel.add_child(title)

	for index in 3:
		var button := Button.new()
		button.name = "DraftChoice%d" % index
		button.focus_mode = Control.FOCUS_ALL
		button.custom_minimum_size = Vector2(500.0, 64.0)
		var choice_index := index
		button.pressed.connect(func() -> void:
			_select_choice_index(choice_index)
		)
		panel.add_child(button)
		_choice_buttons.append(button)


func _sync_choice_buttons() -> void:
	for index in _choice_buttons.size():
		var button := _choice_buttons[index]
		if index >= _current_choices.size():
			button.visible = false
			continue
		var choice := _current_choices[index]
		button.visible = true
		button.text = "%s\n%s" % [choice["title"], choice["description"]]


func _prototype_choices() -> Array[Dictionary]:
	var choices: Array[Dictionary] = []
	if _choice_provider != null and _choice_provider.has_method("prototype_choices"):
		for choice in _choice_provider.prototype_choices():
			choices.append(choice.duplicate(true))
		return choices
	for choice in PROTOTYPE_CHOICES:
		choices.append(choice.duplicate(true))
	return choices


func _emit_draft_opened(level_event: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_draft_opened"):
		_event_bus.emit_draft_opened({
			"level": level_event.get("level", 0),
			"choices": _current_choices.duplicate(true),
		})


func _emit_choice_selected(choice: Dictionary) -> void:
	if _event_bus != null and _event_bus.has_method("emit_draft_choice_selected"):
		_event_bus.emit_draft_choice_selected({
			"choice_id": choice["id"],
			"title": choice["title"],
		})


func _set_always_process(node: Node) -> void:
	if node == null:
		return
	node.process_mode = Node.PROCESS_MODE_ALWAYS
