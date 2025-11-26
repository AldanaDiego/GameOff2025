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