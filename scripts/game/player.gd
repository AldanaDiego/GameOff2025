class_name Player extends VehicleBody3D
## Player movement and actions

const STEER_SPEED: float = 1.5
const MAX_STEER: float = 0.4
const ENGINE_POWER: float = 50.0
const BRAKE_STRENGTH: float = 2.0
const MAX_SPEED_FOR_ACCEL: float = 6.0
const MAX_ENGINE_ACCEL: float = 100.0
const DRILL_ACTION_HOLD_TIME: float = 2.5
const DRILL_ACTION_DURATION: float = 3.0

enum PlayerState { INACTIVE, IDLE, DRILL_CHARGE, DRILL, RADAR_CHARGE, RADAR }

@export var _wheel_dust: Array[GPUParticles3D]

@onready var camera_controller: Node3D = $CameraController
@onready var _animation: AnimationPlayer = $scorpion/AnimationPlayer

var _state: PlayerState
var _drill_button_pressed: float
var _drill_action_timer: Timer
var _current_water_spot: WaterSpot
var _speed_stage: int

func _ready() -> void:
    _animation.playback_default_blend_time = 1
    _drill_button_pressed = 0.0
    _state = PlayerState.IDLE
    _drill_action_timer = GlobalTools.add_timer_node(self, DRILL_ACTION_DURATION)
    _current_water_spot = null
    _speed_stage = 0

func _physics_process(delta) -> void:
    if Input.is_action_just_pressed("drill_menu_ok"):
        _state = PlayerState.DRILL_CHARGE
        _drill_button_pressed = 0.0
        brake = 1
        #TODO play animation

    elif Input.is_action_pressed("drill_menu_ok"):
        if _state == PlayerState.DRILL_CHARGE:
            _drill_button_pressed += delta
            if _drill_button_pressed >= DRILL_ACTION_HOLD_TIME:
                _start_drill_action()

    elif Input.is_action_just_released("drill_menu_ok"):
        if _state == PlayerState.DRILL_CHARGE:
            _state = PlayerState.IDLE
            brake = 0
            _animation.play("Idle")

    #TODO same as before for radar action

    if _state == PlayerState.IDLE:
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
                engine_force = ENGINE_POWER * (-1.0 if accel_input < 0 else 1.0)
        else:
            engine_force = 0.0

        if engine_force == 0:
            _animation.play("Idle")
        else:
            _animation.play("Drive_Backward" if engine_force < 0 else "Drive_Forward")

    var new_speed_stage: int = floori(linear_velocity.length() / 3.5)
    if _speed_stage != new_speed_stage:
        _speed_stage = new_speed_stage
        for particles in _wheel_dust:
            particles.emitting = _speed_stage > 0
            particles.amount_ratio = 0.5 if _speed_stage < 2 else 1.0

## Digs into the ground interacting with a nearby [class WaterSpot]
func _start_drill_action() -> void:
    _state = PlayerState.DRILL
    linear_velocity = Vector3.ZERO
    print_debug("Digging!")
    _drill_action_timer.start()
    await _drill_action_timer.timeout
    if _current_water_spot != null:
        _current_water_spot.extract()
    print_debug("Finished diggin!")
    brake = 0
    _state = PlayerState.IDLE
    #TODO play animation, dig

## Updates references to WaterSpot when entering or leaving their Area3D
func set_current_water_spot(spot: WaterSpot) -> void:
    _current_water_spot = spot
