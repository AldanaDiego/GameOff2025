class_name Game extends Node3D
## Game manager

const TICK: float = 1.5

@onready var _player: Player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _stage: Stage = $Stage
@onready var _weather: Weather = $Weather
@onready var _player_ui: PlayerUI = $PlayerUI
@onready var _weather_ui: WeatherUI = $WeatherUI
@onready var _game_over_ui: GameOverUI = $GameOver
@onready var _pause_menu: PauseMenu = $PauseMenu

var _tick_timer: Timer
var _is_game_paused: bool

signal on_game_retry
signal on_game_return_to_title

#region Setup and process

func _ready() -> void:
    _is_game_paused = false
    _stage.on_stage_ready.connect(_on_stage_ready)
    _player.on_radar_used.connect(_on_player_radar_used)
    _player.on_water_depleted.connect(_on_player_water_depleted)
    _stage.on_all_treasures_found.connect(_on_stage_all_treasures_found)
    _game_over_ui.on_retry_pressed.connect(_on_game_over_retry_pressed)
    _game_over_ui.on_return_pressed.connect(_on_game_over_return_pressed)
    _pause_menu.on_retry_pressed.connect(_on_pause_retry_pressed)
    _pause_menu.on_return_pressed.connect(_on_pause_return_pressed)
    
    _tick_timer = GlobalTools.add_timer_node(self, TICK)
    _tick_timer.one_shot = false
    _tick_timer.process_mode = Node.PROCESS_MODE_PAUSABLE
    _tick_timer.timeout.connect(_on_tick)
    _tick_timer.start()

func _process(_delta) -> void:
    if !_is_game_paused and Input.is_action_pressed("pause"):
        _pause_menu_show()
    _camera.position.x = _player.camera_controller.global_position.x
    _camera.position.z = _player.camera_controller.global_position.z
    _camera.rotation_degrees.y = _player.rotation_degrees.y + 180

#endregion

#region Public functions

## Plays vfx of the game. Needed when loading the game for WebGL build
func preview_vfx() -> void:
    _stage.preview_vfx()
    await _player.preview_vfx()

#region Private functions

## Every second updates game behaviour
func _on_tick() -> void:
    _weather.update()
    _weather_ui.update(_weather.get_current_temperature(), _weather.get_current_temperature_level())
    _player.update(_weather.get_current_temperature_level())
    _player_ui.update(_player.get_water_tank(), _player.get_inner_temperature())

## Pauses the game and shows menu
func _pause_menu_show() -> void:
    _is_game_paused = true
    _pause_menu.show_menu()
    get_tree().paused = true

#endregion

#region Stage signal connects

## Listens to stage finished spawning
func _on_stage_ready() -> void:
    pass

## Shows game over UI when player runs out of water
func _on_player_water_depleted() -> void:
    _player.set_state(Player.PlayerState.INACTIVE)
    _game_over_ui.show_menu(true)

## Shows game over UI when player finds all treasure on stage
func _on_stage_all_treasures_found() -> void:
    _player.set_state(Player.PlayerState.INACTIVE)
    _game_over_ui.show_menu(false)

## Checks if there is any [class WaterSpot] nearby the player when the radar is used
func _on_player_radar_used() -> void:
    var pos = _player.global_position
    _stage.reveal_diggable_spots(pos)

#endregion

#region Menu signal connects

## Listens to retry button on game over menu
func _on_game_over_retry_pressed() -> void:
    await _game_over_ui.hide_menu()
    on_game_retry.emit()

## Listens to return to title button on game over menu
func _on_game_over_return_pressed() -> void:
    await _game_over_ui.hide_menu()
    on_game_return_to_title.emit()

## Listens to retry button on pause menu
func _on_pause_retry_pressed() -> void:
    await _pause_menu.hide_menu()
    get_tree().paused = false
    _is_game_paused = false
    _player.set_state(Player.PlayerState.INACTIVE)
    on_game_retry.emit()

## Listens to return button on pause menu
func _on_pause_return_pressed() -> void:
    await _pause_menu.hide_menu()
    get_tree().paused = false
    _is_game_paused = false

#endregion
