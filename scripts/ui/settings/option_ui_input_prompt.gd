class_name OptionUIInputPrompt extends Control
## Prompt menu shown for the keyboard and controller input settings

@onready var _prompt_timer: Timer = $PromptTimer
@onready var _timer_label: Label = $PanelContainer/VBoxContainer/TimerLabel
@onready var _info_label: Label = $PanelContainer/VBoxContainer/InfoLabel
@onready var _sfx: AudioStreamPlayer = $SFX

var _state: GlobalConstants.State
var _setting_section: String
var _setting_key: String
var _is_keyboard: bool

signal input_prompt_result(bool, int)

## Initializes the prompt menu
func _ready():
    _prompt_timer.wait_time = GlobalConstants.SETTINGS_INPUT_PROMPT_TIME
    _state = GlobalConstants.State.HIDDEN
    _prompt_timer.timeout.connect(_on_timeout)

## Updates prompt close timer
func _process(_delta: float) -> void:
    if !_prompt_timer.is_stopped():
        _timer_label.text = str(ceili(_prompt_timer.time_left))

## Listens to user input to get a key or button press. It validates the keycode and sends it to a [class OptionUIInput].
func _input(event: InputEvent) -> void:
    if _state == GlobalConstants.State.ACTIVE:
        if _is_keyboard and event is InputEventKey and event.is_pressed():
            event = event as InputEventKey
            if !InputDisplay.is_valid_key(event.keycode): 
                _play_error_sfx()
                _info_label.text = "SETTING_INPUT_ERROR_INVALID"
            elif Settings.is_keycode_used(_setting_section, event.keycode):
                _play_error_sfx()
                _info_label.text = "SETTING_INPUT_ERROR_USED"
            else:
                _play_ok_sfx()
                input_prompt_result.emit(true, event.keycode)
                _prompt_hide()
        elif !_is_keyboard and event is InputEventJoypadButton and event.is_pressed():
            event = event as InputEventJoypadButton
            if !InputDisplay.is_valid_controller_button(event.button_index):
                _play_error_sfx()
                _info_label.text = "SETTING_INPUT_ERROR_INVALID"
            elif Settings.is_keycode_used(_setting_section, event.button_index):
                _play_error_sfx()
                _info_label.text = "SETTING_INPUT_ERROR_USED"
            else:
                _play_ok_sfx()
                input_prompt_result.emit(true, event.button_index)
                _prompt_hide()
        elif !_is_keyboard and event is InputEventJoypadMotion and !GlobalTools.is_on_deadzone(event):
            event = event as InputEventJoypadMotion
            var trigger_code = GlobalTools.controller_trigger_to_button(event.axis)
            if !InputDisplay.is_valid_controller_button(trigger_code):
                _play_error_sfx()
                _info_label.text = "SETTING_INPUT_ERROR_INVALID"
            elif Settings.is_keycode_used(_setting_section, trigger_code):
                _play_error_sfx()
                _info_label.text = "SETTING_INPUT_ERROR_USED"
            else:
                _play_ok_sfx()
                input_prompt_result.emit(true, trigger_code)
                _prompt_hide()

## Closes this prompt menu after the timer runs out. Notifies a [class OptionUIInput]
func _on_timeout() -> void:
    input_prompt_result.emit(false, -1)
    _prompt_hide()  

## Closes this prompt menu
func _prompt_hide() -> void:
    _state = GlobalConstants.State.HIDDEN
    _timer_label.text = ""
    visible = false

## Plays SFX when input error occurs
func _play_error_sfx() -> void:
    _sfx.stream = GlobalConstants.MENU_CANCEL_SFX
    _sfx.play()

## Plays SFX when succesfully reading a new input
func _play_ok_sfx() -> void:
    _sfx.stream = GlobalConstants.MENU_OK_SFX
    _sfx.play()

## Shows this prompt menu, linked to a [class OptionUIInput].
func prompt_show(section: String, key: String) -> void:
    _is_keyboard = section == GlobalConstants.CONFIG_SECTION_KEYBOARD
    _setting_section = section
    _setting_key = key
    _info_label.text = ""
    visible = true
    _play_ok_sfx()
    _state = GlobalConstants.State.ACTIVE
    _prompt_timer.start()