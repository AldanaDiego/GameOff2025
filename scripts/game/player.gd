class_name Player extends VehicleBody3D
## Player movement and actions

const STEER_SPEED: float = 1.5
const MAX_STEER: float = 0.4
const ENGINE_POWER: float = 50.0
const BRAKE_STRENGTH: float = 2.0
const MAX_SPEED_FOR_ACCEL: float = 6.0
const MAX_ENGINE_ACCEL: float = 100.0
const DRILL_ACTION_HOLD_TIME: float = 1.2
const RADAR_ACTION_HOLD_TIME: float = 2.5
const DRILL_ACTION_DURATION: float = 2.5
const RADAR_ACTION_DURATION: float = 2.5

enum PlayerState { INACTIVE, IDLE, DRILL_CHARGE, DRILL, RADAR_CHARGE, RADAR }

@export var _wheel_dust: Array[GPUParticles3D]
@export var _water_tank_material: ShaderMaterial

@onready var camera_controller: Node3D = $CameraController
@onready var _animation: AnimationPlayer = $scorpion/AnimationPlayer
@onready var _radar_wave_vfx: GPUParticles3D = $RadarWaveParticles

var _state: PlayerState
var _drill_button_pressed: float
var _drill_action_timer: Timer
var _radar_button_pressed: float
var _radar_action_timer: Timer
var _current_water_spot: WaterSpot
var _speed_stage: int
var _water_tank_level: float
var _inner_temperature: float

signal on_radar_used

func _ready() -> void:
    _animation.playback_default_blend_time = 0.6
    _drill_button_pressed = 0.0
    _radar_button_pressed = 0.0
    _state = PlayerState.IDLE
    _drill_action_timer = GlobalTools.add_timer_node(self, DRILL_ACTION_DURATION)
    _radar_action_timer = GlobalTools.add_timer_node(self, RADAR_ACTION_DURATION)
    _current_water_spot = null
    _speed_stage = 0
    _water_tank_level = 100.0
    _inner_temperature = 0.0

func _physics_process(delta) -> void:
    if Input.is_action_just_pressed("drill_menu_ok") and _state == PlayerState.IDLE:
        _state = PlayerState.DRILL_CHARGE
        _drill_button_pressed = 0.0
        brake = 1
        _animation.play("Drill_Prepare")

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

    if Input.is_action_just_pressed("radar_menu_back") and _state == PlayerState.IDLE:
        _state = PlayerState.RADAR_CHARGE
        _radar_button_pressed = 0.0
        brake = 1
        _animation.play("Radar_Prepare")

    elif Input.is_action_pressed("radar_menu_back"):
        if _state == PlayerState.RADAR_CHARGE:
            _radar_button_pressed += delta
            if _radar_button_pressed >= RADAR_ACTION_HOLD_TIME:
                _start_radar_action()

    elif Input.is_action_just_released("radar_menu_back"):
        if _state == PlayerState.RADAR_CHARGE:
            _state = PlayerState.IDLE
            brake = 0
            _animation.play("Idle")

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
    _animation.play("Drill")
    linear_velocity = Vector3.ZERO
    
    _drill_action_timer.start()
    await _drill_action_timer.timeout
    
    if _current_water_spot != null:
        _current_water_spot.extract()
    brake = 0
    _animation.play("Idle")
    _state = PlayerState.IDLE

## Highlights nearby digging spots
func _start_radar_action() -> void:
    _state = PlayerState.RADAR
    _animation.play("Idle")
    linear_velocity = Vector3.ZERO
    _radar_wave_vfx.emitting = true
    
    _radar_action_timer.start()
    await _radar_action_timer.timeout

    brake = 0
    _radar_wave_vfx.emitting = false
    _state = PlayerState.IDLE
    on_radar_used.emit()

## Updates references to WaterSpot when entering or leaving their Area3D
func set_current_water_spot(spot: WaterSpot) -> void:
    _current_water_spot = spot

## Gets current amount of water in player's tank
func get_water_tank() -> float:
    return _water_tank_level

## Gets the current inner temperature of the player
func get_inner_temperature() -> float:
    return _inner_temperature

## Update water consumption and inner temperature
func update(world_temp_level: int) -> void:
    var water_consumption: float = 0.0
    var temp_increase: float = 0.0
    
    if _current_water_spot != null and _current_water_spot.get_state() == WaterSpot.State.EXTRACTING:
        water_consumption = -5
        temp_increase = -5    
    else:
        water_consumption = (floori(_inner_temperature / 25) + 1) * (_speed_stage + 1) * 0.1
        temp_increase = ((world_temp_level + 1) * (_speed_stage + 1) * 0.15) if world_temp_level < 2 else 3.5
        
    _water_tank_level = clampf(
            _water_tank_level - water_consumption,
            0.0,
            100.0
    )
    _inner_temperature = clampf(
        _inner_temperature + temp_increase,
        0.0,
        100.0
    )
    _water_tank_material.set_shader_parameter("liquid_height", _water_tank_level / 100.0)
