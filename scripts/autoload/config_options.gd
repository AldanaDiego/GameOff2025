extends Node
## Contains declarations for each setting used in the settings menu.
##
## Declares each configurable setting for the settings menu.
## Settings are identified by a section (ex: Video, Audio) 
## and key (ex: Language, WindowSize) to be compatible with 
## Godot [ConfigFile]. Each setting declares a default value and, 
## in the case of dropdown select settings, each available option
## as a internal value and display value pair.

enum OptionType { SELECT, SLIDER, INPUT_KEYBOARD, INPUT_CONTROLLER }

enum ScreenMode { FULLSCREEN, WINDOW }

var _settings := {
	"General": {
		"Language": {
			"type": OptionType.SELECT,
			"options": {
				"en": "SETTINGS_OPTION_LANGUAGE_ENGLISH",
				"es": "SETTINGS_OPTION_LANGUAGE_SPANISH"
			},
			"default": "en"
		},
		"TempDisplay": {
			"type": OptionType.SELECT,
			"options": {
				GlobalConstants.TempDisplay.CELCIUS: "Celcius",
				GlobalConstants.TempDisplay.FAHRENHEIT: "Fahrenheit"
			},
			"default": GlobalConstants.TempDisplay.CELCIUS
		}
	},
	"Audio": {
		"Master": {
			"type": OptionType.SLIDER,
			"default": 1
		},
		"Music": {
			"type": OptionType.SLIDER,
			"default": 1
		},
		"SFX": {
			"type": OptionType.SLIDER,
			"default": 1
		}
	},
	"Video": {
		"ScreenMode" : {
			"type": OptionType.SELECT,
			"options": {
				ScreenMode.FULLSCREEN: "SETTINGS_OPTION_SCREEN_FULLSCREEN",
				ScreenMode.WINDOW: "SETTINGS_OPTION_SCREEN_WINDOW"
			},
			"default": ScreenMode.FULLSCREEN
		},
		"WindowSize" : {
			"type": OptionType.SELECT,
			"options": {
				Vector2(1920,1080): "1920x1080",
				Vector2(1280,720): "1280x720",
				Vector2(1024,600): "1024x600"
			},
			"default": Vector2(1920,1080)
		}
	},
	"Keyboard": {
		"MoveUp": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_W,
			"input_action": "move_up"
		},
		"MoveDown": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_S,
			"input_action": "move_down"
		},
		"MoveLeft": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_A,
			"input_action": "move_left"
		},
		"MoveRight": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_D,
			"input_action": "move_right"
		},
		"DrillMenuOk": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_F,
			"input_action": "drill_menu_ok"
		},
		"RadarMenuBack": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_R,
			"input_action": "radar_menu_back"
		},
		"MenuTabLeft": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_Q,
			"input_action": "menu_tab_left"
		},
		"MenuTabRight": {
			"type": OptionType.INPUT_KEYBOARD,
			"default": KEY_E,
			"input_action": "menu_tab_right"
		}
	},
	"Controller": {
		"DrillMenuOk": {
			"type": OptionType.INPUT_CONTROLLER,
			"default": JOY_BUTTON_A,
			"input_action": "drill_menu_ok"
		},
		"RadarMenuBack": {
			"type": OptionType.INPUT_CONTROLLER,
			"default": JOY_BUTTON_B,
			"input_action": "radar_menu_back"
		},
		"MenuTabLeft": {
			"type": OptionType.INPUT_CONTROLLER,
			"default": JOY_BUTTON_LEFT_SHOULDER,
			"input_action": "menu_tab_left"
		},
		"MenuTabRight": {
			"type": OptionType.INPUT_CONTROLLER,
			"default": JOY_BUTTON_RIGHT_SHOULDER,
			"input_action": "menu_tab_right"
		}
	}
}

## Checks if value is valid for a certain (section, key) setting
func is_valid_value(section: String, key: String, value) -> bool:
	var setting = _settings[section][key]
	match setting["type"]:
		OptionType.SLIDER:
			return (value is int or value is float) and value >= 0 and value <= 1
		OptionType.SELECT:
			return value in setting["options"].keys()
		OptionType.INPUT_KEYBOARD:
			return value is int and InputDisplay.is_valid_key(value)
		OptionType.INPUT_CONTROLLER:
			return value is int and InputDisplay.is_valid_controller_button(value)
		_:
			return false

## Gets the default value for a certain (section, key) setting.
func get_default_value(section: String, key: String) -> Variant:
	return _settings[section][key]["default"]

## Gets the available options for a (section, key) setting. Setting must be of type SELECT.
func get_options(section: String, key: String) -> Dictionary:
	return _settings[section][key]["options"]

## Returns all the settings for a particular section.
func get_section_settings_list(section: String) -> Dictionary:
	return _settings[section]

## Returns the [class InputMap] action associated with an input setting. Setting must be of type INPUT_KEYBOARD or INPUT_CONTROLLER
func get_input_action(section: String, key: String) -> String:
	return _settings[section][key]["input_action"]
