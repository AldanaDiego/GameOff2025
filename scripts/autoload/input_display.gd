extends Node
## Contains tools for displaying UI input icons

## Allows access to the different input icons for each action to
## display them in the UI.

const BASE_PATH := "res://assets/inputs/"
const MOTION_MOUSE_TIME: float = 2.5

enum InputMethod {KEYBOARD, XBOX, SWITCH, PLAYSTATION}

signal on_input_method_changed(InputMethod)

var _keycode_regex: RegEx
var _current_input_method: InputMethod
var _allowed_special_keys: Array
var _allowed_controller_buttons: Array
var _mouse_motion_timer: Timer

## Initializes regex
func _ready() -> void:
	_current_input_method = InputMethod.KEYBOARD
	_keycode_regex = RegEx.new()
	_keycode_regex.compile("[A-Z]|[0-9]")
	_allowed_special_keys = [KEY_SHIFT, KEY_SPACE, KEY_CTRL, KEY_UP, KEY_DOWN, KEY_LEFT, KEY_RIGHT]
	_allowed_controller_buttons = [
		JOY_BUTTON_A,
		JOY_BUTTON_B,
		JOY_BUTTON_X,
		JOY_BUTTON_Y,
		JOY_BUTTON_BACK,
		JOY_BUTTON_START,
		JOY_BUTTON_LEFT_SHOULDER,
		JOY_BUTTON_RIGHT_SHOULDER,
		GlobalTools.controller_trigger_to_button(JOY_AXIS_TRIGGER_LEFT),
		GlobalTools.controller_trigger_to_button(JOY_AXIS_TRIGGER_RIGHT)
	]
	_mouse_motion_timer = GlobalTools.add_timer_node(self, MOTION_MOUSE_TIME)
	_mouse_motion_timer.timeout.connect(_hide_mouse)

## Listens to all game input to display icons according to keyboard or controller
func _input(event: InputEvent) -> void:
	var changed := false
	if event is InputEventMouseMotion:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_mouse_motion_timer.start()
	elif (event is InputEventJoypadButton) or (event is InputEventJoypadMotion):
		if event is InputEventJoypadMotion and GlobalTools.is_on_deadzone(event):
			return
		if _current_input_method == InputMethod.KEYBOARD:
			var controller_name = Input.get_joy_name(0)
			if controller_name.contains("Xbox"):
				_current_input_method = InputMethod.XBOX
			elif controller_name.contains("Nintendo Switch"):
				_current_input_method = InputMethod.SWITCH
			elif controller_name.contains("Playstation") or controller_name.contains("PS1") or controller_name.contains("PS2") or controller_name.contains("PS3") or controller_name.contains("PS4") or controller_name.contains("PS5"):
				_current_input_method = InputMethod.PLAYSTATION
			else:
				_current_input_method = InputMethod.XBOX
			changed = true
	elif _current_input_method != InputMethod.KEYBOARD:
		_current_input_method = InputMethod.KEYBOARD
		changed = true
	
	if changed:
		on_input_method_changed.emit(_current_input_method)

## Hides the mouse cursor
func _hide_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

## Checks if an action name is for a movement axis
func _is_movement_action(action: String) -> bool:
	return action in ["MoveUp", "MoveLeft", "MoveDown", "MoveRight"]

## Obtains the icon associated to an action for the currently used input method
func get_action_icon(action: String) -> CompressedTexture2D:
	if _current_input_method == InputMethod.KEYBOARD:
		var key = Settings.get_setting_value(GlobalConstants.CONFIG_SECTION_KEYBOARD, action)
		return get_keyboard_key_icon(key)
	elif _is_movement_action(action):
		return get_controller_direction_icon(action)
	else:
		var button = Settings.get_setting_value(GlobalConstants.CONFIG_SECTION_CONTROLLER, action)
		return get_controller_button_icon(button)

## Obtains the keyboard icon associated to a key
func get_keyboard_key_icon(key: int) -> CompressedTexture2D:
	var path = BASE_PATH + "keyboard/keyboard_" + OS.get_keycode_string(key).to_lower() + ".png"
	return load(path)

## Obtains the controller icon associated to an action
func get_controller_button_icon(button: int) -> CompressedTexture2D:
	var path = BASE_PATH
	match _current_input_method:
		InputMethod.SWITCH:
			path += "switch/"
		InputMethod.PLAYSTATION:
			path += "playstation/"
		InputMethod.XBOX, _:
			path += "xbox/"
	path += "button_" + str(button) + ".png"
	return load(path)

## Validates if a key is valid to be used as a keyboard action input
func is_valid_key(key: int) -> bool:
	var key_string = OS.get_keycode_string(key)
	if key in _allowed_special_keys:
		return true
	if key_string.length() == 1 and _keycode_regex.search(key_string):
		return true
	return false

## Validates if a key is valid to be used as a controller action input
func is_valid_controller_button(key: int) -> bool:
	return key in _allowed_controller_buttons

## Obtains the controller icon associated to a movement direction
func get_controller_direction_icon(action: String) -> CompressedTexture2D:
	var path = BASE_PATH
	match _current_input_method:
		InputMethod.SWITCH:
			path += "switch/"
		InputMethod.PLAYSTATION:
			path += "playstation/"
		InputMethod.XBOX, _:
			path += "xbox/"
	match action:
		"MoveUp":
			path += "stick_l_up.png"
		"MoveLeft":
			path += "stick_l_left.png"
		"MoveDown":
			path += "stick_l_down.png"
		"MoveRight", _:
			path += "stick_l_right.png"
	return load(path)
