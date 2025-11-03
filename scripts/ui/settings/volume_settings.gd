extends SettingSectionMenu
## Sub menu for the settings menu in charge of Volume section settings.

@onready var _master_volume_slider: OptionUI = $SettingsScroll/SettingsList/MasterVolume
@onready var _music_volume_slider: OptionUI = $SettingsScroll/SettingsList/MusicVolume
@onready var _sfx_volume_slider: OptionUI = $SettingsScroll/SettingsList/SFXVolume

## Initializes the menu and its [class OptionUI]
func _ready() -> void:
	super._ready()
	_settings = [_master_volume_slider, _music_volume_slider, _sfx_volume_slider]
	_scroll = $SettingsScroll
	
	_master_volume_slider.on_value_changed.connect(_change_volume)
	_music_volume_slider.on_value_changed.connect(_change_volume)
	_sfx_volume_slider.on_value_changed.connect(_change_volume)
	
	_master_volume_slider.setup("Audio", "Master", Settings.get_setting_value("Audio", "Master"))
	_music_volume_slider.setup("Audio", "Music", Settings.get_setting_value("Audio", "Music"))
	_sfx_volume_slider.setup("Audio", "SFX", Settings.get_setting_value("Audio", "SFX"))

## Change an audio bus volume when OptionUI setting is changed
func _change_volume(section: String, key: String, value) -> void:
	Settings.set_setting_value(section, key, value)
	var bus_index = AudioServer.get_bus_index(key)
	if value < 0.01:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
		AudioServer.set_bus_mute(bus_index, false)
