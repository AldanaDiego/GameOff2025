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
@export var _drill_sfx: AudioStream
@export var _radar_ping_sfx: AudioStream

@onready var camera_controller: Node3D = $CameraController
@onready var _animation: AnimationPlayer = $scorpion/AnimationPlayer
@onready var _radar_wave_vfx: GPUParticles3D = $RadarWaveParticles
@onready var _drill_particles_left: GPUParticles3D = $DrillParticlesLeft
@onready var _drill_particles_right: GPUParticles3D = $DrillParticlesRight
@onready var _sfx: SfxPlayer = $SfxPlayer
@onready var _motor_sfx: AudioStreamPlayer3D = $MotorSFX

var _state: PlayerState
var _drill_button_pressed: float
var _drill_action_timer: Timer
var _radar_button_pressed: float
var _radar_action_timer: Timer
var _current_water_spot: WaterSpot
var _current_treasure_spot: TreasureSpot
var _current_hideout: Hideout
var _speed_stage: int
var _water_tank_level: float
var _inner_temperature: float

signal on_radar_used
signal on_water_depleted

#region Setup and process

func _ready() -> void:
	_animation.playback_default_blend_time = 0.6
	_drill_button_pressed = 0.0
	_radar_button_pressed = 0.0
	_state = PlayerState.INACTIVE
	_drill_action_timer = GlobalTools.add_timer_node(self, DRILL_ACTION_DURATION)
	_radar_action_timer = GlobalTools.add_timer_node(self, RADAR_ACTION_DURATION)
	_current_water_spot = null
	_current_hideout = null
	_speed_stage = 0
	set_water_tank(50.0)
	_inner_temperature = 0.0

func _physics_process(delta) -> void:
	if Input.is_action_just_pressed("drill_menu_ok") and _state == PlayerState.IDLE:
		_state = PlayerState.DRILL_CHARGE
		_drill_button_pressed = 0.0
		engine_force = 0.0
		brake = 1.0
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
		engine_force = 0.0
		brake = 1.0
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
		if accel_input != 0.0:
			_motor_sfx.pitch_scale = 1.2
		else:
			_motor_sfx.pitch_scale = 1.0

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
		# End of copied code lol

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

#endregion

#region Private functions

## Digs into the ground interacting with a nearby [class WaterSpot]
func _start_drill_action() -> void:
	_state = PlayerState.DRILL
	_animation.play("Drill")
	linear_velocity = Vector3.ZERO
	_sfx.play_sfx(_drill_sfx, -10)
	_drill_particles_left.emitting = true
	_drill_particles_right.emitting = true
	
	_drill_action_timer.start()
	await _drill_action_timer.timeout
	
	if _current_water_spot != null:
		_current_water_spot.extract()
	elif _current_treasure_spot != null:
		_current_treasure_spot.extract()

	brake = 0
	_drill_particles_left.emitting = false
	_drill_particles_right.emitting = false
	_animation.play("Idle")
	_state = PlayerState.IDLE

## Highlights nearby digging spots
func _start_radar_action() -> void:
	_state = PlayerState.RADAR
	_animation.play("Idle")
	linear_velocity = Vector3.ZERO
	_radar_wave_vfx.emitting = true
	_sfx.play_sfx(_radar_ping_sfx)
	
	_radar_action_timer.start()
	await _radar_action_timer.timeout

	brake = 0
	_radar_wave_vfx.emitting = false
	_state = PlayerState.IDLE
	on_radar_used.emit()

#endregion

#region Public functions

## Updates references to WaterSpot when entering or leaving their Area3D
func set_current_water_spot(spot: WaterSpot) -> void:
	_current_water_spot = spot

## Updates references to TreasureSpot when entering or leaving their Area3D
func set_current_treasure_spot(spot: TreasureSpot) -> void:
	_current_treasure_spot = spot

## Updates references to Hideout when entering or leaving their Area3D
func set_current_hideout(hideout: Hideout) -> void:
	_current_hideout = hideout

## Gets current amount of water in player's tank
func get_water_tank() -> float:
	return _water_tank_level

## Sets current amount of water in player's tank
func set_water_tank(new_level: float) -> void:
	_water_tank_level = clampf(new_level, 0.0, 100.0)
	_water_tank_material.set_shader_parameter("liquid_height", _water_tank_level / 100.0)

## Gets the current inner temperature of the player
func get_inner_temperature() -> float:
	return _inner_temperature

## Sets the player state
func set_state(new_state: PlayerState) -> void:
	_state = new_state
	if _state == PlayerState.INACTIVE:
		_motor_sfx.stop()
		steering = 0.0
		brake = 0.5
	else:
		brake = 0
		if !_motor_sfx.playing:
			_motor_sfx.play()

## Update water consumption and inner temperature
func update(world_temp_level: int) -> void:
	var water_consumption: float = 0.0
	var temp_increase: float = 0.0
	
	if _current_water_spot != null and _current_water_spot.get_state() == WaterSpot.State.EXTRACTING:
		water_consumption = -5
		temp_increase = -5
	elif _current_hideout != null:
		water_consumption = (floori(_inner_temperature / 25) + 1) * (_speed_stage + 1) * 0.1
		temp_increase = -1.0 if world_temp_level < 2 else -0.5
	else:
		water_consumption = (floori(_inner_temperature / 25) + 1) * (_speed_stage + 1) * 0.1
		temp_increase = ((world_temp_level + 1.5) * (_speed_stage + 1) * 0.15) if world_temp_level < 2 else 4.0
		
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

	_water_tank_material.set_shader_parameter("liquid_height", lerp(0.155, 1.0, _water_tank_level / 100.0))

	if _water_tank_level == 0.0:
		on_water_depleted.emit()

## Plays all vfx on the player. Needed when loading the game for WebGL build
func preview_vfx() -> void:
	var radar_charge_vfx: GPUParticles3D = $scorpion/Armature/Skeleton3D/RadarBone/RadarChargeParticles
	
	radar_charge_vfx.emitting = true
	_radar_wave_vfx.emitting = true
	_drill_particles_left.emitting = true
	_drill_particles_right.emitting = true

	for wheel in _wheel_dust:
		wheel.emitting = true
	
	var timer = GlobalTools.add_timer_node(self, 1.5)
	timer.start()
	await timer.timeout

	radar_charge_vfx.emitting = false
	_radar_wave_vfx.emitting = false
	_drill_particles_left.emitting = false
	_drill_particles_right.emitting = false
	for wheel in _wheel_dust:
		wheel.emitting = false

	timer.start(1)
	await timer.timeout

	timer.queue_free()

#endregion
