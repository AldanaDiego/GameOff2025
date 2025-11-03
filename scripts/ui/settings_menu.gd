class_name SettingsMenu extends Control
## Manages the settings menu. Contains several sub menus in tabs.
##
## Manages the settings menu. Allows to navigate through several 
## sub menus for each settings section.

@onready var _save_button: Button = $SaveButton
@onready var _tab_container: TabContainer = $TabContainer
@onready var _tab_navbar_left: TextureButton = $TabNavbar/LeftButton
@onready var _tab_navbar_right: TextureButton = $TabNavbar/RightButton
@onready var _tab_navbar_buttons: HBoxContainer = $TabNavbar/TabNavbarButtons
@onready var _keyboard_settings: KeyboardSettings = $TabContainer/KeyboardSettings
@onready var _controller_settings: ControllerSettings = $TabContainer/ControllerSettings
@onready var _menu_sfx: AudioStreamPlayer = $MenuSFX

var _current_index = 0
var _state: GlobalConstants.State
var _navigation_timer: Timer

signal on_save_pressed

## Initializes the save settings button and the tabs navigation. 
func _ready() -> void:
	_state = GlobalConstants.State.HIDDEN
	_navigation_timer = GlobalTools.add_ui_navigation_timer(self)

	_save_button.icon = InputDisplay.get_action_icon("MenuBack")
	_tab_navbar_left.texture_normal = InputDisplay.get_action_icon("MenuTabLeft")
	_tab_navbar_right.texture_normal = InputDisplay.get_action_icon("MenuTabRight")
	
	InputDisplay.on_input_method_changed.connect(_on_input_method_changed)
	_keyboard_settings.on_keyboard_setting_changed.connect(_on_input_setting_changed)
	_controller_settings.on_controller_setting_changed.connect(_on_input_setting_changed)

	_save_button.pressed.connect(_on_save_button_pressed)
	for i in _tab_navbar_buttons.get_child_count():
		var button: Button = _tab_navbar_buttons.get_child(i)
		button.pressed.connect(func(): _change_tab(i))
		if i == 0:
			button.set_pressed_no_signal(true)

	for submenu: SettingSectionMenu in _tab_container.get_children():
		submenu.on_state_changed.connect(_on_submenu_state_changed)

	_tab_navbar_left.pressed.connect(func(): _change_to_next_tab(-1))
	_tab_navbar_right.pressed.connect(func(): _change_to_next_tab(1))
	_tab_container.get_child(0).set_focused(true, false)

## Listens to input to navigate through tabs
func _input(event: InputEvent) -> void:
	if _state == GlobalConstants.State.ACTIVE and _navigation_timer.is_stopped():
		if event.is_action_pressed("menu_tab_left"):
			_menu_sfx.stream = GlobalConstants.MENU_MOVE_SFX
			_menu_sfx.play()
			_change_to_next_tab(-1)
			_navigation_timer.start()
		elif event.is_action_pressed("menu_tab_right"):
			_menu_sfx.stream = GlobalConstants.MENU_MOVE_SFX
			_menu_sfx.play()
			_change_to_next_tab(1)
			_navigation_timer.start()
		elif event.is_action_pressed("menu_back"):
			_on_save_button_pressed()

## Shows or hides this UI.
func change_visible(visibility: bool, duration: float, delay: float = 0) -> void:
	if visibility:
		show()
		await GlobalTools.ui_tween(self, true, Vector2(0, -50), duration, delay, Tween.TRANS_CUBIC)
		_state = GlobalConstants.State.ACTIVE
	else:
		_state = GlobalConstants.State.HIDDEN
		await GlobalTools.ui_tween(self, false, Vector2(0, -50), duration, delay, Tween.TRANS_CUBIC)
		hide()
	_change_tab(0)

## Saves changes made on settings
func _on_save_button_pressed() -> void:
	if _state == GlobalConstants.State.ACTIVE:
		_menu_sfx.stream = GlobalConstants.MENU_OK_SFX
		_menu_sfx.play()
		Settings.save_settings()
		on_save_pressed.emit()

## Updates the current tab by counting steps from the currently active tab.
func _change_to_next_tab(steps: int) -> void:
	_change_tab(GlobalTools.cycle_index(_current_index + steps, _tab_navbar_buttons.get_child_count()))

## Changes the current tab by index
func _change_tab(index: int) -> void:
	_current_index = index
	_tab_container.current_tab = index
	_tab_navbar_buttons.get_child(_current_index).button_pressed = true
	for i in _tab_container.get_child_count():
		_tab_container.get_child(i).set_focused(i == _current_index, _state == GlobalConstants.State.ACTIVE)

## Listen to state changes in children submenus
func _on_submenu_state_changed(submenu_state: GlobalConstants.State) -> void:
	if submenu_state == GlobalConstants.State.ACTIVE:
		_navigation_timer.start()
	_state = submenu_state

## Listen to changes in input method to show appropiate icons
func _on_input_method_changed(_method: InputDisplay.InputMethod) -> void:
	_save_button.icon = InputDisplay.get_action_icon("MenuBack")
	_tab_navbar_left.texture_normal = InputDisplay.get_action_icon("MenuTabLeft")
	_tab_navbar_right.texture_normal = InputDisplay.get_action_icon("MenuTabRight")

## Listen to changes in keyboard settings to show appropiate icons
func _on_input_setting_changed(_section: String, key: String, _value) -> void:
	match key:
		"MenuBack":
			_save_button.icon = InputDisplay.get_action_icon("MenuBack")
		"MenuTabLeft":
			_tab_navbar_left.texture_normal = InputDisplay.get_action_icon("MenuTabLeft")
		"MenuTabRight":
			_tab_navbar_right.texture_normal = InputDisplay.get_action_icon("MenuTabRight")