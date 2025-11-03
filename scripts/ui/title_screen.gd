class_name TitleScreen extends Control
## Manages the title screen menu of the game

@onready var _title_label: Control = $Title
@onready var _button_group: Control = $Buttons
@onready var _start_button: Button = $Buttons/StartButton
@onready var _settings_button: Button = $Buttons/SettingsButton
@onready var _credits_button: Button = $Buttons/CreditsButton
@onready var _exit_button: Button = $Buttons/ExitButton
@onready var _menu_sfx: AudioStreamPlayer = $MenuSFX

signal on_start_pressed
signal on_settings_pressed
signal on_credits_pressed
signal on_exit_pressed

var _current_index: int
var _state: GlobalConstants.State
var _navigation_timer: Timer

## Initializes the menu. Connects signals for button press and button focus entered.
func _ready() -> void:
	_state = GlobalConstants.State.HIDDEN
	_current_index = 0
	_start_button.grab_focus()
	_start_button.pressed.connect(func(): _on_button_pressed(on_start_pressed))
	_settings_button.pressed.connect(func(): _on_button_pressed(on_settings_pressed))
	_credits_button.pressed.connect(func(): _on_button_pressed(on_credits_pressed))
	_exit_button.pressed.connect(func(): _on_button_pressed(on_exit_pressed))

	_navigation_timer = GlobalTools.add_ui_navigation_timer(self)
	
	for i in _button_group.get_child_count():
		var button: Button = _button_group.get_child(i)
		button.focus_entered.connect(func(): _set_current_index(i))
		
	await GlobalTools.ui_tween(_button_group, true, Vector2(25, 0), 1, 1.25, Tween.TRANS_BACK)
	_state = GlobalConstants.State.ACTIVE

## Listens to menu navigation input, changing the currently focused button.
func _input(event: InputEvent) -> void:
	if _state == GlobalConstants.State.ACTIVE:
		if event.is_action("menu_ok"):
			_button_group.get_child(_current_index).pressed.emit()
		elif _navigation_timer.is_stopped():
			var movement = GlobalTools.get_input_axis_movement(event, JOY_AXIS_LEFT_Y)
			if movement != 0:
				_navigation_timer.start()
				_update_current_index(movement)
				_menu_sfx.stream = GlobalConstants.MENU_MOVE_SFX
				_menu_sfx.play()

## Shows or hides this UI.
func change_visible(visibility: bool, duration: float, delay: float = 0) -> void:
	if visibility:
		_set_current_index(0)
		show()
		GlobalTools.ui_tween(_title_label, true, Vector2(0, 50), duration, delay, Tween.TRANS_CUBIC)
		await GlobalTools.ui_tween(_button_group, true, Vector2(0, 50), duration, delay, Tween.TRANS_CUBIC)
		_state = GlobalConstants.State.ACTIVE
	else:
		_state = GlobalConstants.State.HIDDEN
		GlobalTools.ui_tween(_title_label, false, Vector2(0, 50), duration, delay, Tween.TRANS_CUBIC)
		await GlobalTools.ui_tween(_button_group, false, Vector2(0, 50), duration, delay, Tween.TRANS_CUBIC)
		hide()

## Sets the currently focused button by its button list index.
func _set_current_index(index: int) -> void:
	_current_index = index
	_button_group.get_child(_current_index).grab_focus()

## Sets the currently focused button by counting steps from the current index.
func _update_current_index(step: int) -> void:
	_current_index = GlobalTools.cycle_index(_current_index + step, _button_group.get_child_count())
	_button_group.get_child(_current_index).grab_focus()

## Listen to button presses and emit corresponding signal
func _on_button_pressed(button_signal: Signal) -> void:
	if _state == GlobalConstants.State.ACTIVE:
		_menu_sfx.stream = GlobalConstants.MENU_OK_SFX
		_menu_sfx.play()
		_state = GlobalConstants.State.BUSY
		button_signal.emit()