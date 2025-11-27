class_name ControllerSettings extends SettingSectionMenu

@onready var _drill_ok_option: OptionUI = $SettingsScroll/SettingsList/DrillOk
@onready var _radar_back_option: OptionUI = $SettingsScroll/SettingsList/RadarBack
@onready var _pause_option: OptionUI = $SettingsScroll/SettingsList/Pause
@onready var _tab_left_option: OptionUI = $SettingsScroll/SettingsList/TabLeft
@onready var _tab_right_option: OptionUI = $SettingsScroll/SettingsList/TabRight

signal on_controller_setting_changed

## Initializes the menu and its [class OptionUI]
func _ready() -> void:
	super._ready()
	_settings = [_drill_ok_option, _radar_back_option, _pause_option,_tab_left_option, _tab_right_option]
	_scroll = $SettingsScroll

	for option: OptionUIInput in _settings:
		option.on_input_prompt_start.connect(_on_input_prompt_start)
		option.on_input_prompt_end.connect(_on_input_prompt_end)
		option.on_value_changed.connect(_on_input_changed)
		option.set_input_prompt($InputPrompt)

	_drill_ok_option.setup("Controller", "DrillMenuOk", Settings.get_setting_value("Controller", "DrillMenuOk"))
	_radar_back_option.setup("Controller", "RadarMenuBack", Settings.get_setting_value("Controller", "RadarMenuBack"))
	_pause_option.setup("Controller", "Pause", Settings.get_setting_value("Controller", "Pause"))
	_tab_left_option.setup("Controller", "MenuTabLeft", Settings.get_setting_value("Controller", "MenuTabLeft"))
	_tab_right_option.setup("Controller", "MenuTabRight", Settings.get_setting_value("Controller", "MenuTabRight"))

## Listens to when an input prompt shows up and changes the state of the settings menu to busy.
func _on_input_prompt_start() -> void:
	_change_state(GlobalConstants.State.BUSY)

## Listens to when an input prompt closes and changes the state of the settings menu to active.
func _on_input_prompt_end() -> void:
	_change_state(GlobalConstants.State.ACTIVE)

## Changes the game input maps when an input setting is changed
func _on_input_changed(section: String, key: String, value) -> void:
	var default_button_code = ConfigOptions.get_default_value(section, key)
	var previous_button_code = Settings.get_setting_value(section, key)
	var input_action = ConfigOptions.get_input_action(section, key)
	var input_event: InputEvent
	
	if previous_button_code == value and previous_button_code != default_button_code:
		input_event = _code_to_input_event(default_button_code)
		InputMap.action_erase_event(input_action, input_event)

	input_event = _code_to_input_event(previous_button_code)
	InputMap.action_erase_event(input_action, input_event)

	Settings.set_setting_value(section, key, value)
	input_event = _code_to_input_event(value)
	InputMap.action_add_event(input_action, input_event)
	Settings.save_settings()
	on_controller_setting_changed.emit(section, key, value)

## Creates an [class InputEvent] from a button code
func _code_to_input_event(button_code: int) -> InputEvent:
	var input_event
	if GlobalTools.is_controller_trigger(button_code):
		input_event = InputEventJoypadMotion.new()
		input_event.axis = GlobalTools.controller_code_to_trigger(button_code)
	else:
		input_event = InputEventJoypadButton.new()
		input_event.button_index = button_code
	return input_event