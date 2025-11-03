extends Node
## Manages the [ConfigFile] with all the game settings.
##
## Enables read and write access to the [ConfigFile] with the 
## game settings.

const SETTINGS_FILE_PATH: String = "user://settings.ini"

var _config: ConfigFile

## Attempts to load the settings file. It is created if the file didn't exist previously.
func _ready() -> void:
	_config = ConfigFile.new()
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		_create_settings_file()
	else:
		_load_settings()
		_validate_controls()

## Creates a new settings file.
func _create_settings_file() -> void:
	save_settings()

## Loads the settings file.
func _load_settings() -> void:
	_config.load(SETTINGS_FILE_PATH)

## Validates a section on the settings file, looking for repeated inputs
func _validate_controls() -> void:
	var sections = [GlobalConstants.CONFIG_SECTION_KEYBOARD, GlobalConstants.CONFIG_SECTION_CONTROLLER]
	for section in sections:
		var actions = ConfigOptions.get_section_settings_list(section)
		var inputs = []
		for action in actions:
			var value = get_setting_value(section, action)
			if inputs.has(value):
				_config.erase_section(section)
				return
			else:
				inputs.append(value)

## Saves changes on the settings file.
func save_settings() -> void:
	_config.save(SETTINGS_FILE_PATH)

## Gets the current value for a (section, key) setting. If the setting value is not present or is invalid in the settings file it returns the setting default value. This method validates and cleans invalid value settings, in case the settings file has been manually modified
func get_setting_value(section: String, key: String) -> Variant:
	if _config.has_section_key(section, key):
		var value = _config.get_value(section, key)
		if ConfigOptions.is_valid_value(section, key, value):
			return value
		else:
			_config.set_value(section, key, null)
			save_settings()
	return ConfigOptions.get_default_value(section, key)

## Changes the value of a setting. This change is reflected in runtime but is not saved to the settings file yet. Use method save_settings for saving changed settings to file.
func set_setting_value(section: String, key: String, value):
	_config.set_value(section, key, value)

## Checks if a keycode is already used for an input action.
func is_keycode_used(section: String, keycode: int) -> bool:
	for setting in ConfigOptions.get_section_settings_list(section):
		if get_setting_value(section, setting) == keycode:
			return true
	return false
