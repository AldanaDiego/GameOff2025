class_name GeneralSettings extends SettingSectionMenu
## Sub menu for the settings menu in charge of General section settings.

@onready var _language_select: OptionUI = $SettingsScroll/SettingsList/Language

#TODO add input display help option

## Initializes the menu and its [class OptionUI]
func _ready() -> void:
	super._ready()
	_settings = [_language_select]
	_scroll = $SettingsScroll
	
	var current_locale = Settings.get_setting_value("General", "Language")
	_language_select.on_value_changed.connect(_on_language_changed)
	_language_select.setup("General", "Language", current_locale)

## Changes the game locale when language changes on settings.
func _on_language_changed(section: String, key: String, value) -> void:
	Settings.set_setting_value(section, key, value)
	TranslationServer.set_locale(value)
