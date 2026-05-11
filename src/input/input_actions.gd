class_name InputActions
extends RefCounted

const MOVE_LEFT := "move_left"
const MOVE_RIGHT := "move_right"
const MOVE_UP := "move_up"
const MOVE_DOWN := "move_down"
const DASH := "dash"
const INTERACT := "interact"
const PAUSE := "pause"


## Ensures first-playable gameplay actions and default bindings exist.
func ensure_default_actions() -> void:
	_add_action_with_keys(MOVE_LEFT, [KEY_A, KEY_LEFT])
	_add_action_with_keys(MOVE_RIGHT, [KEY_D, KEY_RIGHT])
	_add_action_with_keys(MOVE_UP, [KEY_W, KEY_UP])
	_add_action_with_keys(MOVE_DOWN, [KEY_S, KEY_DOWN])
	_add_action_with_keys(DASH, [KEY_SPACE])
	_add_action_with_keys(INTERACT, [KEY_E])
	_add_action_with_keys(PAUSE, [KEY_ESCAPE])
	_add_action_with_keys("ui_accept", [KEY_ENTER, KEY_E])
	_add_action_with_keys("ui_cancel", [KEY_ESCAPE])
	_add_joy_button(DASH, JOY_BUTTON_A)
	_add_joy_button(INTERACT, JOY_BUTTON_X)
	_add_joy_button(PAUSE, JOY_BUTTON_START)
	_add_joy_button("ui_accept", JOY_BUTTON_A)
	_add_joy_button("ui_cancel", JOY_BUTTON_B)
	_add_joy_button(MOVE_LEFT, JOY_BUTTON_DPAD_LEFT)
	_add_joy_button(MOVE_RIGHT, JOY_BUTTON_DPAD_RIGHT)
	_add_joy_button(MOVE_UP, JOY_BUTTON_DPAD_UP)
	_add_joy_button(MOVE_DOWN, JOY_BUTTON_DPAD_DOWN)


## Returns normalized X/Z movement input as Vector2(x, z).
func movement_vector() -> Vector2:
	var raw := Vector2(
		Input.get_action_strength(MOVE_RIGHT) - Input.get_action_strength(MOVE_LEFT),
		Input.get_action_strength(MOVE_DOWN) - Input.get_action_strength(MOVE_UP)
	)
	if raw.length() > 1.0:
		return raw.normalized()
	return raw


## Returns true on the dash action press edge.
func dash_just_pressed() -> bool:
	return Input.is_action_just_pressed(DASH)


## Returns true on the interact action press edge.
func interact_just_pressed() -> bool:
	return Input.is_action_just_pressed(INTERACT)


func _add_action_with_keys(action: String, keycodes: Array[int]) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)
	for keycode in keycodes:
		_add_key(action, keycode)


func _add_key(action: String, keycode: int) -> void:
	if _has_key_event(action, keycode):
		return
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action, event)


func _add_joy_button(action: String, button_index: JoyButton) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action, 0.2)
	if _has_joy_button_event(action, button_index):
		return
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	InputMap.action_add_event(action, event)


func _has_key_event(action: String, keycode: int) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventKey and event.physical_keycode == keycode:
			return true
	return false


func _has_joy_button_event(action: String, button_index: JoyButton) -> bool:
	for event in InputMap.action_get_events(action):
		if event is InputEventJoypadButton and event.button_index == button_index:
			return true
	return false
