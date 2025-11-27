extends Node
## Contains all constants used globally through the game

enum State { ACTIVE, HIDDEN, BUSY, IDLE }
enum TempDisplay { CELCIUS, FAHRENHEIT }

const CONFIG_SECTION_KEYBOARD = "Keyboard"
const CONFIG_SECTION_CONTROLLER = "Controller"

const UI_SHOW_TWEEN_DURATION: float = 0.75
const UI_HIDE_TWEEN_DURATION: float = 0.5
const UI_NAVIGATION_COOLDOWN: float = 0.175
const SETTINGS_INPUT_PROMPT_TIME: float = 5
const JOYSTICK_DEADZONE: float = 0.5

const MENU_OK_SFX: AudioStream = preload("res://assets/sfx/menu_accept.mp3")
const MENU_MOVE_SFX: AudioStream = preload("res://assets/sfx/menu_move.mp3")
const MENU_CANCEL_SFX: AudioStream = preload("res://assets/sfx/menu_cancel.mp3")

const PLAYER_RADAR_DISTANCE: float = 50.0

const CAMERA_DEFAULT_POSITION: Vector3 = Vector3(0.0, 2.5, -4.5)
const CAMERA_DEFAULT_ROTATION: Vector3 = Vector3(-10.0, 180.0, 0.0)
const CAMERA_INTRO_POSITION: Vector3 = Vector3(3.0, 2.0, 3.5)
const CAMERA_INTRO_ROTATION: Vector3 = Vector3(-5.0, 35.0, 0.0)