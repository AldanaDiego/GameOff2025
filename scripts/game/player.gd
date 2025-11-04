class_name Player extends VehicleBody3D
## Player movement and actions

#TODO u.u

const STEER_SPEED: float = 4
const MAX_STEER: float = 0.8
const ENGINE_POWER: float = 250

func _physics_process(delta):
    var steer_input: float = Input.get_axis("move_left", "move_right")
    steer_input = steer_input if abs(steer_input) > GlobalConstants.JOYSTICK_DEADZONE else 0.0
    steering = move_toward(steering, steer_input * MAX_STEER, delta * STEER_SPEED)

    var accel_input: float = Input.get_axis("move_down", "move_up")
    accel_input = accel_input if abs(accel_input) > GlobalConstants.JOYSTICK_DEADZONE else 0.0
    engine_force = accel_input * ENGINE_POWER
