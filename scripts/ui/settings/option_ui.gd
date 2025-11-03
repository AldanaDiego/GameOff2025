class_name OptionUI extends Control
## Generic class for settings option UI.
## Should not be directly instantiated.
## 
## Defines structure for settings UI. Each type of setting UI 
## (ex: Select, Slider) defined in ConfigOptions should have 
## their own scene implementing this class. Scripts inheriting 
## from this class must manually set the _focus_indicator attribute.

var _section: String
var _key: String
var _focus_indicator: TextureRect

signal on_value_changed(section: String, key: String, value)

## Links this OptionUI to a (section, key) setting.
func setup(section: String, key: String, _start_value) -> void:
	_section = section
	_key = key

## Abstract function for changing the value of this setting via left/right button presses.
func change_option_value(_steps: int) -> void:
	pass

## Abstract function for changing the value of this setting via OK button press opening a menu.
func change_option_prompt() -> void:
	pass

## Sets if this OptionUI should be the focused one inside its menu.
func set_focused(focused: bool) -> void:
	_focus_indicator.visible = focused
