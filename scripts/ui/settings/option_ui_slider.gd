extends OptionUI
## UI to modify a setting of Slider type.

@onready var _slider: Slider = $Container/Slider

## Initializes the setting UI
func _ready() -> void:
	_focus_indicator = $Container/CenterContainer/FocusArrow
	_slider.value_changed.connect(_on_slider_value_changed)

## Setups the setting UI
func setup(section: String, key: String, start_value) -> void:
	super.setup(section, key, start_value)
	_slider.value = start_value
	on_value_changed.emit(section, key, _slider.value)

## Emits signal on _slider moved
func _on_slider_value_changed(value: float) -> void:
	on_value_changed.emit(_section, _key, value)

## Changes this setting value by adding a step amount
func change_option_value(steps: int) -> void:
	_slider.value += steps * _slider.step
