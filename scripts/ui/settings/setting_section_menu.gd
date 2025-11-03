class_name SettingSectionMenu extends Control
## Generic class for sub menus in each tab of the settings menu.
## Should not be directly instantiated.
##
## Defines structure for settings sub menus. Each sub menu contains 
## a list of [class OptionUI] that it can navigate through input.
## Scripts inheriting from this class must manually set the _settings 
## and _scroll attribute.

@export var _sfx: AudioStreamPlayer

var _settings: Array[OptionUI]
var _scroll: ScrollContainer
var _current_index: int
var _state: GlobalConstants.State
var _navigation_timer: Timer

signal on_state_changed(State)

## Initializes this menu.
func _ready() -> void:
	_current_index = 0
	_state = GlobalConstants.State.HIDDEN
	_navigation_timer = GlobalTools.add_ui_navigation_timer(self)

## Listens to user input to navigate through the menu.
func _input(event: InputEvent) -> void:
	if _state == GlobalConstants.State.ACTIVE and _navigation_timer.is_stopped():
		if event.is_action("menu_ok"):
			_settings[_current_index].change_option_prompt()
		else:
			var movement_y = GlobalTools.get_input_axis_movement(event, JOY_AXIS_LEFT_Y)
			if movement_y != 0:
				_navigation_timer.start()
				_update_current_index(movement_y)
				_sfx.stream = GlobalConstants.MENU_MOVE_SFX
				_sfx.play()
				return
			var movement_x = GlobalTools.get_input_axis_movement(event, JOY_AXIS_LEFT_X)
			if movement_x != 0:
				_navigation_timer.start()
				_settings[_current_index].change_option_value(movement_x)
				return

## Changes the currently selected OptionUI inside this menu by counting steps from the current index.
func _update_current_index(step: int) -> void:
	_set_current_index(GlobalTools.cycle_index(_current_index + step, _settings.size()))

## Changes the currently selected OptionUI inside this menu.
func _set_current_index(index: int) -> void:
	_current_index = index
	_scroll.scroll_vertical = GlobalTools.get_scroll_position(_current_index, _settings.size(), _scroll.size.y)
	for i in _settings.size():
		_settings[i].set_focused(i == _current_index)

## Changes the current status of this menu.
func _change_state(new_state: GlobalConstants.State) -> void:
	_state = new_state
	if _state == GlobalConstants.State.ACTIVE:
		_navigation_timer.start() #Little cooldown to avoid navigation when exiting input prompt on keyboard/controller settings
	on_state_changed.emit(new_state)

## Set this menu as the current active under the settings menu tabs.
func set_focused(focused: bool, is_parent_active: bool) -> void:
	_state = GlobalConstants.State.ACTIVE if focused and is_parent_active else GlobalConstants.State.HIDDEN
	if _state == GlobalConstants.State.ACTIVE:
		_set_current_index(0)
