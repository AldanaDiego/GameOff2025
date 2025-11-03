extends Node
## Contains functions used globally through the game

var _timer: Timer

func _ready() -> void:
	_timer = add_timer_node(self)

## Adds a [class Timer] node to [param parent] to be used in UI navigation
func add_ui_navigation_timer(parent: Node) -> Timer:
	var timer = Timer.new()
	timer.wait_time = GlobalConstants.UI_NAVIGATION_COOLDOWN
	timer.one_shot = true
	parent.add_child(timer)
	return timer

## Adds a [class Timer] node to [param parent]
func add_timer_node(parent: Node, duration: float = 1) -> Timer:
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	parent.add_child(timer)
	return timer

## Verifies a value to be used as list index. If index overflows, returns it to the beginning. If index underflows, put it at the end.
func cycle_index(value: int, max_value: int) -> int:
	value = value % max_value
	if value < 0:
		return max_value + value
	elif value >= max_value:
		return value - max_value
	return value

## Gives a new code to controller trigger axis (RT, LT)
func controller_trigger_to_button(trigger_code: int) -> int:
	return trigger_code + JOY_BUTTON_SDL_MAX

## Checks if a controller button code is a trigger axis (RT, LT)
func is_controller_trigger(button_code: int) -> bool:
	return button_code > JOY_BUTTON_SDL_MAX

## Returns the trigger axis code for a modified button code
func controller_code_to_trigger(button_code: int) -> int:
	return button_code - JOY_BUTTON_SDL_MAX

## Checks if a [class InputEventJoypadMotion] is deadzone
func is_on_deadzone(event: InputEventJoypadMotion) -> bool:
	return abs(event.axis_value) < GlobalConstants.JOYSTICK_DEADZONE

## Checks an [class InputEvent] to listen for axis movement
func get_input_axis_movement(event: InputEvent, axis: int) -> int:
	var action_negative = "move_up" if axis == JOY_AXIS_LEFT_Y else "move_left"
	var action_positive = "move_down" if axis == JOY_AXIS_LEFT_Y else "move_right"
	if event is InputEventJoypadMotion:
		if event.axis == axis and !is_on_deadzone(event):
			return -1 if event.axis_value < 0 else 1
	else:
		if event.is_action(action_negative):
			return -1
		elif event.is_action(action_positive):
			return 1
	return 0

## Gets the position for [class ScrollContainer] based on current selected index
func get_scroll_position(index: int, children_count: int, container_size: float) -> int:
	if index == 0:
		return 0
	elif index == children_count - 1:
		return roundi(container_size)
	return roundi((container_size / children_count) * index)

## Animates the enter/exit of an UI element
func ui_tween(ui: Control, appear: bool, offset: Vector2, time: float, delay: float, transition_type: int) -> void:
	var tweener: Tween
	var original_position = ui.position

	if appear:
		ui.modulate.a = 0
		ui.position += offset
		if delay > 0:
			await _run_timer(delay)
		tweener = ui.create_tween()
		tweener.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tweener.parallel().tween_property(ui, "modulate:a", 1, time).set_trans(transition_type)
		tweener.parallel().tween_property(ui, "position", original_position, time).set_trans(transition_type)
	else:
		ui.modulate.a = 1
		if delay > 0:
			await _run_timer(delay)
		tweener = ui.create_tween()
		tweener.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tweener.parallel().tween_property(ui, "modulate:a", 0, time)
		tweener.parallel().tween_property(ui, "position", ui.position + offset, time).set_trans(transition_type)
	
	await tweener.finished
	ui.position = original_position

## Animates the position and rotation of a camera
func camera_tween(camera: Camera3D, start_pos: Vector3, end_pos: Vector3, start_rotation: Vector3, end_rotation: Vector3, time: float) -> Tween:
	camera.position = start_pos
	camera.rotation_degrees = start_rotation
	var tweener: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(camera, "position", end_pos, time)
	tweener.parallel().tween_property(camera, "rotation_degrees", end_rotation, time)
	return tweener

## Animates the position, rotation and FOV of a camera
func perspective_camera_tween(camera: Camera3D, start_pos: Vector3, end_pos: Vector3, start_rotation: Vector3, end_rotation: Vector3, start_fov: float, end_fov: float, time: float) -> Tween:
	camera.position = start_pos
	camera.rotation_degrees = start_rotation
	camera.fov = start_fov
	var tweener: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	tweener.parallel().tween_property(camera, "position", end_pos, time)
	tweener.parallel().tween_property(camera, "rotation_degrees", end_rotation, time)
	tweener.parallel().tween_property(camera, "fov", end_fov, time)
	return tweener

## Transforms a String with comma sepparated numbers into a Vector3
func string_to_vector(arg: String) -> Vector3:
	var vector = Vector3.ZERO
	var split = arg.split(",")
	vector.x = split[0].to_float()
	vector.y = split[1].to_float()
	vector.z = split[2].to_float()
	return vector

## Runs a one shot timer
func _run_timer(time: float)-> void:
	_timer.start(time)
	await _timer.timeout
