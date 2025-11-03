extends OptionUI
## UI to modify a setting of Select type.
##
## UI to modify a select setting. Listens to button press and 
## input to cycle between a set of available options

@onready var left_button: Button = $Container/LeftButton
@onready var right_button: Button = $Container/RightButton
@onready var value_label: Label = $Container/Value

var select_options: Dictionary
var current_index: int

## Initializes buttons
func _ready() -> void:
	left_button.pressed.connect(func(): _change_selected(-1))
	right_button.pressed.connect(func(): _change_selected(1))

## Setups the setting display. Obtains all the available options for the (section, key) setting.
func setup(section: String, key: String, start_value) -> void:
	super.setup(section, key, start_value)
	_focus_indicator = $Container/CenterContainer/FocusArrow
	select_options = {}
	
	var i = 0
	var config = ConfigOptions.get_options(section, key)
	for value in config:
		select_options[i] = {
			"option_value": value,
			"option_display": config[value]
		}
		if value == start_value:
			current_index = i
			value_label.text = config[value]
		i += 1
	
	on_value_changed.emit(_section, _key, select_options[current_index]["option_value"])

## Changes the currently selected option by counting steps from the current one.
func _change_selected(steps: int) -> void:
	current_index = GlobalTools.cycle_index(current_index + steps, select_options.size())
	value_label.text = select_options[current_index]["option_display"]
	on_value_changed.emit(_section, _key, select_options[current_index]["option_value"])

## Changes the value of this setting by changing the current index in the options list.
func change_option_value(steps: int) -> void:
	_change_selected(steps)
