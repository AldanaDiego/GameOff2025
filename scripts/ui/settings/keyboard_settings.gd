class_name KeyboardSettings extends SettingSectionMenu
## Sub menu for settings in charge of keyboard controls

#TODO add pause action settings

@onready var _drill_ok_option: OptionUI = $SettingsScroll/SettingsList/DrillOk
@onready var _radar_back_option: OptionUI = $SettingsScroll/SettingsList/RadarBack
@onready var _move_up_option: OptionUI = $SettingsScroll/SettingsList/MoveUp
@onready var _move_down_option: OptionUI = $SettingsScroll/SettingsList/MoveDown
@onready var _move_left_option: OptionUI = $SettingsScroll/SettingsList/MoveLeft
@onready var _move_right_option: OptionUI = $SettingsScroll/SettingsList/MoveRight
@onready var _tab_left_option: OptionUI = $SettingsScroll/SettingsList/TabLeft
@onready var _tab_right_option: OptionUI = $SettingsScroll/SettingsList/TabRight

signal on_keyboard_setting_changed

## Initializes the menu and its [class OptionUI]
func _ready() -> void:
	super._ready()
	_settings = [_drill_ok_option, _radar_back_option, _move_up_option, _move_down_option, _move_left_option, _move_right_option, _tab_left_option, _tab_right_option]
	_scroll = $SettingsScroll

	for option: OptionUIInput in _settings:
		option.on_input_prompt_start.connect(_on_input_prompt_start)
		option.on_input_prompt_end.connect(_on_input_prompt_end)
		option.on_value_changed.connect(_on_input_changed)
		option.set_input_prompt($InputPrompt)

	_drill_ok_option.setup("Keyboard", "DrillMenuOk", Settings.get_setting_value("Keyboard", "DrillMenuOk"))
	_radar_back_option.setup("Keyboard", "RadarMenuBack", Settings.get_setting_value("Keyboard", "RadarMenuBack"))
	_move_up_option.setup("Keyboard", "MoveUp", Settings.get_setting_value("Keyboard", "MoveUp"))
	_move_down_option.setup("Keyboard", "MoveDown", Settings.get_setting_value("Keyboard", "MoveDown"))
	_move_left_option.setup("Keyboard", "MoveLeft", Settings.get_setting_value("Keyboard", "MoveLeft"))
	_move_right_option.setup("Keyboard", "MoveRight", Settings.get_setting_value("Keyboard", "MoveRight"))
	_tab_left_option.setup("Keyboard", "MenuTabLeft", Settings.get_setting_value("Keyboard", "MenuTabLeft"))
	_tab_right_option.setup("Keyboard", "MenuTabRight", Settings.get_setting_value("Keyboard", "MenuTabRight"))

## Listens to when an input prompt shows up and changes the state of the settings menu to busy.
func _on_input_prompt_start() -> void:
	_change_state(GlobalConstants.State.BUSY)

## Listens to when an input prompt closes and changes the state of the settings menu to active.
func _on_input_prompt_end() -> void:
	_change_state(GlobalConstants.State.ACTIVE)

## Changes the game input maps when an input setting is changed
func _on_input_changed(section: String, key: String, value) -> void:
	var default_keycode = ConfigOptions.get_default_value(section, key)
	var previous_keycode = Settings.get_setting_value(section, key)
	var input_action = ConfigOptions.get_input_action(section, key)
	var input_event = InputEventKey.new()

	if previous_keycode == value and previous_keycode != default_keycode:
		input_event.keycode = default_keycode
		InputMap.action_erase_event(input_action, input_event)
	
	input_event.keycode = previous_keycode
	InputMap.action_erase_event(input_action, input_event)

	Settings.set_setting_value(section, key, value)
	input_event.keycode = value
	InputMap.action_add_event(input_action, input_event)
	Settings.save_settings()
	on_keyboard_setting_changed.emit(section, key, value)
