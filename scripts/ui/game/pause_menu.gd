class_name PauseMenu extends Control

#TODO made interactable with controller

@onready var _return_button: Button = $PanelContainer/VBoxContainer/ReturnButton
@onready var _retry_button: Button = $PanelContainer/VBoxContainer/RetryButton

var _state: GlobalConstants.State

signal on_return_pressed
signal on_retry_pressed

func _ready() -> void:
    _state = GlobalConstants.State.HIDDEN
    _return_button.pressed.connect(func(): if _state == GlobalConstants.State.ACTIVE: on_return_pressed.emit())
    _retry_button.pressed.connect(func(): if _state == GlobalConstants.State.ACTIVE: on_retry_pressed.emit())

#TODO why dont you work
func show_menu() -> void:
    show()
    GlobalTools.ui_tween(self, true, Vector2(0, 25), 1, 0.5, Tween.TRANS_SINE)
    _state = GlobalConstants.State.ACTIVE

func hide_menu() -> void:
    _state = GlobalConstants.State.HIDDEN
    await GlobalTools.ui_tween(self, false, Vector2(0, 25), 1, 0, Tween.TRANS_SINE)
    hide()
