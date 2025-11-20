class_name Game extends Node3D
## Game manager

const TICK: float = 1.5

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _stage: Stage = $Stage
@onready var _weather: Weather = $Weather
@onready var _player_ui: PlayerUI = $PlayerUI
@onready var _weather_ui: WeatherUI = $WeatherUI

var _tick_timer: Timer

func _ready() -> void:
    _stage.on_stage_ready.connect(_on_stage_ready)
    _player.on_radar_used.connect(_on_player_radar_used)
    _tick_timer = GlobalTools.add_timer_node(self, TICK)
    _tick_timer.one_shot = false
    _tick_timer.timeout.connect(_on_tick)
    _tick_timer.start()

func _process(_delta) -> void:
    _camera.position.x = _player.camera_controller.global_position.x
    _camera.position.z = _player.camera_controller.global_position.z
    _camera.rotation_degrees.y = _player.rotation_degrees.y + 180

func _on_stage_ready() -> void:
    pass

## Checks if there is any WaterSpot nearby the player when the radar is used
func _on_player_radar_used() -> void:
    var pos = _player.global_position
    _stage.reveal_diggable_spots(pos)

## Every second updates game behaviour
func _on_tick() -> void:
    _weather.update()
    _weather_ui.update(_weather.get_current_temperature())
    _player.update(_weather.get_current_temperature())
    _player_ui.update(_player.get_water_tank(), _player.get_inner_temperature())