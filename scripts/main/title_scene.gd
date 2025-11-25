class_name TitleScene extends Node3D
## Background scene for title scene

@onready var _player: Player = $Player

func _ready():
    _player.set_state(Player.PlayerState.INACTIVE)
    _player.set_water_tank(100)
