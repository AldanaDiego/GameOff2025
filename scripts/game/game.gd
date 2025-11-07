class_name Game extends Node3D
## Game manager

#TODO implement tick timer and update weather and player (in order)

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D

func _process(_delta):
    _camera.position = _player.camera_controller.global_position
    _camera.rotation_degrees.y = _player.rotation_degrees.y + 180


