extends Node
## Contains all constants used globally through the game

enum State { ACTIVE, HIDDEN, BUSY, IDLE }

const CONFIG_SECTION_KEYBOARD = "Keyboard"
const CONFIG_SECTION_CONTROLLER = "Controller"

const UI_SHOW_TWEEN_DURATION: float = 0.75
const UI_HIDE_TWEEN_DURATION: float = 0.5
const UI_NAVIGATION_COOLDOWN: float = 0.175
const SETTINGS_INPUT_PROMPT_TIME: float = 5
const JOYSTICK_DEADZONE: float = 0.5

#TODO add menu sfx
const MENU_OK_SFX: AudioStream = null
const MENU_MOVE_SFX: AudioStream = null
const MENU_CANCEL_SFX: AudioStream = null