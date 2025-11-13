class_name Game extends Node3D
## Game manager

#TODO implement tick timer and update weather and player (in order)

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _stage: Stage = $Stage

func _ready() -> void:
    _stage.on_stage_ready.connect(_on_stage_ready)

func _process(_delta) -> void:
    _camera.position.x = _player.camera_controller.global_position.x
    _camera.position.z = _player.camera_controller.global_position.z
    _camera.rotation_degrees.y = _player.rotation_degrees.y + 180

func _on_stage_ready() -> void:
    pass
