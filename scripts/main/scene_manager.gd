extends Node
## Main class container for all the game nodes.
##
## Acts as a root node for the game, containing all other nodes.
## Responsible of changing game scenes by swapping and 
## instantiating nodes.

const MUSIC_FADE_OUT: float = 0.5
const SCREEN_FADE_OUT: float = 0.75
const SETTINGS_MENU_APPEAR_DELAY: float = 0.6

enum State { TITLE_SCREEN, IN_TRANSITION, IN_GAME}

@onready var _title_screen: TitleScreen = $TitleScreen
@onready var _settings_menu: SettingsMenu = $SettingsMenu
@onready var _credits: Credits = $Credits
@onready var _music: MusicManager = $MusicManager
@onready var _scene_transition = $SceneTransition
@onready var _title_scene: TitleScene = $TitleScene

var _game_scene_prefab = preload("res://scenes/game/game.tscn")
var _game_scene: Game
var _state: State

#region Game start

## Loads the title screen at the start of the game
func _ready() -> void:
	_state = State.IN_TRANSITION
	await _scene_transition.fade_out()
	_state = State.TITLE_SCREEN
	_title_screen.on_start_pressed.connect(_start_game)
	_title_screen.on_settings_pressed.connect(_show_settings_menu)
	_title_screen.on_credits_pressed.connect(_show_credits)
	_title_screen.on_exit_pressed.connect(_exit_game)
	_settings_menu.on_save_pressed.connect(_hide_settings_menu)
	_credits.on_back_pressed.connect(_hide_credits)
	_music.set_stream(_music.title_screen_music)
	_music.fade_in(3)

## Transitions from title screen to main game scene
func _start_game() -> void:
	if _state == State.TITLE_SCREEN:
		_state = State.IN_TRANSITION
		_music.fade_out(MUSIC_FADE_OUT)
		await _scene_transition.fade_in()
		_title_screen.queue_free()
		_settings_menu.queue_free()
		_title_scene.queue_free()
		_load_game_scene()

		_music.set_stream(_music.game_music)
		_music.fade_in(3)
		_scene_transition.fade_out()
		_state = State.IN_GAME

## Closes the game
func _exit_game() -> void:
	if _state == State.TITLE_SCREEN:
		get_tree().quit()

#endregion

#region Settings

## Shows the settings menu
func _show_settings_menu() -> void:
	if _state == State.TITLE_SCREEN:
		_title_screen.change_visible(false, GlobalConstants.UI_HIDE_TWEEN_DURATION)
		_settings_menu.change_visible(true, GlobalConstants.UI_SHOW_TWEEN_DURATION, SETTINGS_MENU_APPEAR_DELAY)

## Hides the settings menu
func _hide_settings_menu() -> void:
	if _state == State.TITLE_SCREEN:
		_settings_menu.change_visible(false, GlobalConstants.UI_HIDE_TWEEN_DURATION)
		_title_screen.change_visible(true, GlobalConstants.UI_SHOW_TWEEN_DURATION, SETTINGS_MENU_APPEAR_DELAY)

#endregion

#region Game

## Instantiates the main game scene.
func _load_game_scene() -> void:
	_game_scene = _game_scene_prefab.instantiate() as Game
	_game_scene.on_game_retry.connect(_on_game_retry)
	_game_scene.on_game_return_to_title.connect(_on_game_return_to_title)
	add_child(_game_scene)

## Reloads the main game scene after the player selects retry
func _on_game_retry() -> void:
	_state = State.IN_TRANSITION
	_music.fade_out(MUSIC_FADE_OUT)
	await _scene_transition.fade_in()

	_game_scene.on_game_retry.disconnect(_on_game_retry)
	_game_scene.on_game_return_to_title.disconnect(_on_game_return_to_title)
	_game_scene.queue_free()
	_load_game_scene()

	_music.fade_in(3)
	_scene_transition.fade_out()
	_state = State.IN_GAME

## Returns from the game scene to the title scene
func _on_game_return_to_title() -> void:
	_state = State.IN_TRANSITION
	_music.fade_out(MUSIC_FADE_OUT)
	await _scene_transition.fade_in()

	_game_scene.on_game_retry.disconnect(_on_game_retry)
	_game_scene.on_game_return_to_title.disconnect(_on_game_return_to_title)
	_game_scene.queue_free()
	_game_scene = null

	get_tree().reload_current_scene()

#endregion

#region Credits

## Show credits menu
func _show_credits() -> void:
	if _state == State.TITLE_SCREEN:
		_title_screen.change_visible(false, GlobalConstants.UI_HIDE_TWEEN_DURATION)
		_credits.change_visible(true, GlobalConstants.UI_SHOW_TWEEN_DURATION, SETTINGS_MENU_APPEAR_DELAY)

## Hide credits menu
func _hide_credits() -> void:
	if _state == State.TITLE_SCREEN:
		_credits.change_visible(false, GlobalConstants.UI_HIDE_TWEEN_DURATION)
		_title_screen.change_visible(true, GlobalConstants.UI_SHOW_TWEEN_DURATION, SETTINGS_MENU_APPEAR_DELAY)

#endregion
