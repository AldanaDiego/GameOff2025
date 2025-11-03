class_name VideoSettings extends SettingSectionMenu
## Sub menu for the settings menu in charge of Video section settings.

@onready var _screen_mode_select: OptionUI = $SettingsScroll/SettingsList/ScreenMode
@onready var _window_size_select: OptionUI = $SettingsScroll/SettingsList/WindowSize

## Initializes the menu and its [class OptionUI]
func _ready() -> void:
	super._ready()
	_settings = [_screen_mode_select, _window_size_select]
	_scroll = $SettingsScroll
	
	_screen_mode_select.on_value_changed.connect(_on_screen_mode_changed)
	_window_size_select.on_value_changed.connect(_on_resolution_changed)

	var current_screen_mode = Settings.get_setting_value("Video", "ScreenMode")
	_screen_mode_select.setup("Video", "ScreenMode", current_screen_mode)

	var current_window_size = Settings.get_setting_value("Video", "WindowSize")
	_window_size_select.setup("Video", "WindowSize", current_window_size)

## Changes screen mode when OptionUI setting is changed
func _on_screen_mode_changed(section: String, key: String, value) -> void:
	Settings.set_setting_value(section, key, value)
	match value:
		ConfigOptions.ScreenMode.FULLSCREEN:
			get_window().mode = Window.MODE_FULLSCREEN
		ConfigOptions.ScreenMode.WINDOW:
			get_window().mode = Window.MODE_WINDOWED
			get_window().size = Settings.get_setting_value("Video", "WindowSize")

## Changes window size when OptionUI setting is changed
func _on_resolution_changed(section: String, key: String, value) -> void:
	Settings.set_setting_value(section, key, value)
	if Settings.get_setting_value("Video", "ScreenMode") == ConfigOptions.ScreenMode.WINDOW:
		get_window().mode = Window.MODE_WINDOWED
		get_window().size = value
