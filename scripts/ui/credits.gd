class_name Credits extends Control
## Credits menu on title screen

const SECTION_SHOW_TIME: float = 1.5
const SECTION_SHOW_DELAY: float = 1

@export var _sections: Array[Control]

@onready var _back_button: Button = $BackButton
@onready var _sfx: AudioStreamPlayer = $SFX

var _state: GlobalConstants.State

signal on_back_pressed

func _ready() -> void:
	_state = GlobalConstants.State.HIDDEN
	_back_button.icon = InputDisplay.get_action_icon("RadarMenuBack")
	_back_button.pressed.connect(_on_back_button_pressed)
	InputDisplay.on_input_method_changed.connect(func(_method: InputDisplay.InputMethod): _back_button.icon = InputDisplay.get_action_icon("RadarMenuBack"))
	for section in _sections:
		section.hide()

func _input(event):
	if _state == GlobalConstants.State.ACTIVE and event.is_action_pressed("radar_menu_back"):
		_on_back_button_pressed()

## Signals to go back into title screen
func _on_back_button_pressed() -> void:
	if _state == GlobalConstants.State.ACTIVE:
		_sfx.play()
		_state = GlobalConstants.State.BUSY
		on_back_pressed.emit()

## Shows or hides this UI.
func change_visible(visibility: bool, duration: float, delay: float = 0) -> void:
	if visibility:
		_back_button.hide()
		modulate.a = 1
		show()
		for i in _sections.size():
			var section = _sections[i]
			section.show()
			await GlobalTools.ui_tween(section, true, Vector2(0, 10), SECTION_SHOW_TIME, SECTION_SHOW_DELAY + (1 if i == 1 else 0), Tween.TRANS_SINE)
		_back_button.show()
		await GlobalTools.ui_tween(_back_button, true, Vector2(0, 50), SECTION_SHOW_TIME, 0, Tween.TRANS_CUBIC)
		_state = GlobalConstants.State.ACTIVE
	else:
		_state = GlobalConstants.State.HIDDEN
		await GlobalTools.ui_tween(self, false, Vector2(0, -50), duration, delay, Tween.TRANS_CUBIC)
		for section in _sections:
			section.hide()
		hide()