class_name OptionUIInput extends OptionUI
## UI to modify a setting of Input type

@onready var _input_icon: TextureRect = $Container/CenterContainer2/InputIcon

var _state: GlobalConstants.State
var _ui_input_prompt: OptionUIInputPrompt
var _is_keyboard: bool

signal on_input_prompt_start
signal on_input_prompt_end

## Initializes this UI
func _ready() -> void:
	_focus_indicator = $Container/CenterContainer/FocusArrow
	_state = GlobalConstants.State.IDLE

## Setups the setting UI, linking it to a (section, key) setting. 
func setup(section: String, key: String, start_value) -> void:
	super.setup(section, key, start_value)
	_is_keyboard = section == GlobalConstants.CONFIG_SECTION_KEYBOARD
	if _is_keyboard:
		_input_icon.texture = InputDisplay.get_keyboard_key_icon(start_value)
	else:
		_input_icon.texture = InputDisplay.get_controller_button_icon(start_value)

	on_value_changed.emit(section, key, start_value)

## Links this UI to a [class OptionUIInputPrompt] to be shown when this UI is interacted with
func set_input_prompt(input_prompt: OptionUIInputPrompt) -> void:
	_ui_input_prompt = input_prompt

## Called when the [class OptionUIInputPrompt] is hidden. Notifies parent menus to get out of busy status.
func _on_prompt_hidden() -> void:
	on_input_prompt_end.emit()
	_state = GlobalConstants.State.IDLE

## Listens to result of [class OptionUIInputPrompt]. On success it receives a keycode to be associated with a (section, key) setting.
func _input_prompt_result(success: bool, keycode: int) -> void:
	if success:
		on_value_changed.emit(_section, _key, keycode)
		if _is_keyboard:
			_input_icon.texture = InputDisplay.get_keyboard_key_icon(keycode)
		else:
			_input_icon.texture = InputDisplay.get_controller_button_icon(keycode)
	_ui_input_prompt.input_prompt_result.disconnect(_input_prompt_result)
	_on_prompt_hidden()

## Setups and shows the associated [class OptionUIInputPrompt] to receive a new keycode for this UI (section, key) setting.
func change_option_prompt() -> void:
	if _state == GlobalConstants.State.IDLE:
		on_input_prompt_start.emit()
		_state = GlobalConstants.State.ACTIVE
		_ui_input_prompt.prompt_show(_section, _key)
		_ui_input_prompt.input_prompt_result.connect(_input_prompt_result)
