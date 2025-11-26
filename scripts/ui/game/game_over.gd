class_name GameOverUI extends Control

@onready var _label: Label = $Label
@onready var _retry_button: Button = $PanelContainer/VBoxContainer/RetryButton
@onready var _return_button: Button = $PanelContainer/VBoxContainer/BackToTitleButton
@onready var _menu_sfx: AudioStreamPlayer = $SFX

var _state: GlobalConstants.State
var _buttons: Array[Button]
var _navigation_timer: Timer
var _current_index: int

signal on_retry_pressed
signal on_return_pressed

#region Setup and process

func _ready():
	_state = GlobalConstants.State.HIDDEN
	_retry_button.grab_focus()
	_buttons = [_retry_button, _return_button]
	_navigation_timer = GlobalTools.add_ui_navigation_timer(self)
	_retry_button.pressed.connect(func(): _on_button_pressed(on_retry_pressed))
	_return_button.pressed.connect(func(): _on_button_pressed(on_return_pressed))

	for i in _buttons.size():
		_buttons[i].focus_entered.connect(func(): _set_current_index(i))

## Listens to menu navigation input, changing the currently focused button.
func _input(event: InputEvent) -> void:
	if _state == GlobalConstants.State.ACTIVE:
		if event.is_action("drill_menu_ok"):
			_buttons[_current_index].pressed.emit()
		elif _navigation_timer.is_stopped():
			var movement = GlobalTools.get_input_axis_movement(event, JOY_AXIS_LEFT_Y)
			if movement != 0:
				_navigation_timer.start()
				_update_current_index(movement)
				_menu_sfx.stream = GlobalConstants.MENU_MOVE_SFX
				_menu_sfx.play()

#endregion

#region Public functions

func show_menu(is_game_over: bool) -> void:
	_set_current_index(0)
	_label.text = tr("GAME_OVER_LABEL_LOSE") if is_game_over else tr("GAME_OVER_LABEL_WIN")
	show()
	GlobalTools.ui_tween(self, true, Vector2(0, 25), 1, 0.5, Tween.TRANS_SINE)
	_state = GlobalConstants.State.ACTIVE

func hide_menu() -> void:
	_state = GlobalConstants.State.HIDDEN
	await GlobalTools.ui_tween(self, false, Vector2(0, 25), 1, 0, Tween.TRANS_SINE)
	hide()

#endregion

#region Private functions

## Sets the currently focused button by its button list index.
func _set_current_index(index: int) -> void:
	_current_index = index
	_buttons[_current_index].grab_focus()

## Sets the currently focused button by counting steps from the current index.
func _update_current_index(step: int) -> void:
	_current_index = GlobalTools.cycle_index(_current_index + step, _buttons.size())
	_buttons[_current_index].grab_focus()

## Listen to button presses and emit corresponding signal
func _on_button_pressed(button_signal: Signal) -> void:
	if _state == GlobalConstants.State.ACTIVE:
		_menu_sfx.stream = GlobalConstants.MENU_OK_SFX
		_menu_sfx.play()
		_state = GlobalConstants.State.BUSY
		button_signal.emit()

#endregion