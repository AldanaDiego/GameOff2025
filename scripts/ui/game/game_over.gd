class_name GameOverUI extends Control

#TODO made interactable with controller

@onready var _label: Label = $Label
@onready var _retry_button: Button = $PanelContainer/VBoxContainer/RetryButton
@onready var _return_button: Button = $PanelContainer/VBoxContainer/BackToTitleButton

var _state: GlobalConstants.State

signal on_retry_pressed
signal on_return_pressed

func _ready():
    _state = GlobalConstants.State.HIDDEN
    _retry_button.pressed.connect(func(): if _state == GlobalConstants.State.ACTIVE: on_retry_pressed.emit())
    _return_button.pressed.connect(func(): if _state == GlobalConstants.State.ACTIVE: on_return_pressed.emit())

func show_menu(is_game_over: bool) -> void:
    _label.text = tr("GAME_OVER_LABEL_LOSE") if is_game_over else tr("GAME_OVER_LABEL_WIN")
    show()
    GlobalTools.ui_tween(self, true, Vector2(0, 25), 1, 0.5, Tween.TRANS_SINE)
    _state = GlobalConstants.State.ACTIVE

func hide_menu() -> void:
    _state = GlobalConstants.State.HIDDEN
    await GlobalTools.ui_tween(self, false, Vector2(0, 25), 1, 0, Tween.TRANS_SINE)
    hide()