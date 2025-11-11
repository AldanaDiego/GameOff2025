class_name Player extends VehicleBody3D
## Player movement and actions

#TODO u.u

const STEER_SPEED: float = 1.5
const MAX_STEER: float = 0.4
const ENGINE_POWER: float = 50.0
const BRAKE_STRENGTH: float = 2.0
const MAX_SPEED_FOR_ACCEL: float = 6.0
const MAX_ENGINE_ACCEL: float = 100.0

@onready var camera_controller: Node3D = $CameraController
@onready var _animation: AnimationPlayer = $scorpion/AnimationPlayer

func _ready() -> void:
    _animation.playback_default_blend_time = 1

func _physics_process(delta):
    var steer_input: float = Input.get_axis("move_right", "move_left")
    steer_input = steer_input if abs(steer_input) > GlobalConstants.JOYSTICK_DEADZONE else 0.0
    steering = move_toward(steering, steer_input * MAX_STEER, delta * STEER_SPEED)

    var accel_input: float = Input.get_axis("move_down", "move_up")
    accel_input = accel_input if abs(accel_input) > GlobalConstants.JOYSTICK_DEADZONE else 0.0

    var speed: float = linear_velocity.length()

    # I copied this code from Godot Demo Projects I don't really understand it u.u
    # https://github.com/godotengine/godot-demo-projects/tree/master/3d/truck_town
    if !is_zero_approx(accel_input):
        if speed < MAX_SPEED_FOR_ACCEL and !is_zero_approx(speed):
            engine_force = clampf(ENGINE_POWER * MAX_SPEED_FOR_ACCEL * (BRAKE_STRENGTH if accel_input < 0 else 1.0) / speed, 0.0, MAX_ENGINE_ACCEL) * (-BRAKE_STRENGTH if accel_input < 0 else 1.0)
        else:
            engine_force = ENGINE_POWER * (-BRAKE_STRENGTH if accel_input < 0 else 1.0)
    else:
        engine_force = 0.0

    if engine_force == 0:
        _animation.play("Idle")
    else:
        _animation.play("Drive_Backward" if engine_force < 0 else "Drive_Forward")
