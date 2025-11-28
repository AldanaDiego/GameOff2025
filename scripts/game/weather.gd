class_name Weather extends Node3D
## Simulates day/night cycle, sunlight and temperature

const MIN_TEMP: int = 40
const MAX_TEMP: int = 60
const START_TEMP: int = 45
const HEATWAVE_DURATION: int = 10
const BETWEEN_HEATWAVE_DURATION: int = 10
const DEFAULT_SKY_COLOR: Color = Color(0.04, 0.46, 0.77)
const HEATWAVE_SKY_COLOR: Color = Color(0.716, 0.3, 0.15)

enum State { NORMAL, PRE_HEATWAVE, HEATWAVE, POST_HEATWAVE}

@export var _sky: Sky

@onready var _light: DirectionalLight3D = $Light

var _current_temperature: int
var _cycles_since_last_heatwave: int
var _cycles_since_temp_change: int
var _last_temp_change: int
var _last_temp_level: int
var _temp_midpoint: int
var _state: State

func _ready() -> void:
    _sky.sky_material.sky_top_color = DEFAULT_SKY_COLOR
    _current_temperature = START_TEMP
    _cycles_since_last_heatwave = 0
    _cycles_since_temp_change = 0
    _last_temp_change = 0
    _last_temp_level = 0
    _temp_midpoint = roundi((MAX_TEMP + MIN_TEMP) / 2.0)
    _state = State.NORMAL

## Advance temperature cycle
func update() -> void:
    match _state:
        State.NORMAL:
            _temp_advance_normal()
        State.PRE_HEATWAVE:
            _temp_advance_pre_heatwave()
        State.HEATWAVE:
            _temp_advance_heatwave()
        State.POST_HEATWAVE:
            _temp_advance_post_heatwave()

    var temp_level: int = get_current_temperature_level()
    if _last_temp_level != temp_level:
        var target_color: Color
        var target_rotation: Vector3
        match temp_level:
            0:
                target_color = Color.WHITE
                target_rotation = Vector3(-80, -90, 90)
            1:
                target_color = Color(1, 0.8, 0.8)
                target_rotation = Vector3(-85, -90, 90)
            2:
                target_color = Color(1, 0.6, 0.6)
                target_rotation = Vector3(-90, -90, 90)

        var tween: Tween = create_tween()
        tween.tween_property(_light, "light_color", target_color, Game.TICK).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        tween.parallel().tween_property(_light, "rotation_degrees", target_rotation, Game.TICK).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

        if temp_level == 2 or _last_temp_level == 2:
            var target_sky_color: Color = HEATWAVE_SKY_COLOR if temp_level == 2 else DEFAULT_SKY_COLOR
            tween = $WorldEnvironment.create_tween()
            tween.tween_property(_sky.sky_material, "sky_top_color", target_sky_color, Game.TICK).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
        

        _last_temp_level = temp_level
        

## Changes temperature with weighted probability
func _temp_advance_normal() -> void:
    var random: float = randf()
    var chance_to_change: float = _cycles_since_temp_change * 0.25

    if random < chance_to_change:
        random = randf()
        var chance_to_lower: float = (_current_temperature - MIN_TEMP) * 0.05 #0.0 to 1.0
        
        if _cycles_since_last_heatwave <= BETWEEN_HEATWAVE_DURATION: #if last heatwave was recent, more likely to lower temperature
            chance_to_lower += 0.1 * (BETWEEN_HEATWAVE_DURATION - _cycles_since_last_heatwave)
        else: #if last heatwave was long ago, more likely to rise temp
            chance_to_lower -= (_cycles_since_last_heatwave - BETWEEN_HEATWAVE_DURATION) * 0.1

        chance_to_lower = clampf(chance_to_lower, 0.1, 0.9)

        var step: int = -1 if random < chance_to_lower else 1
        _current_temperature = clampi(
            _current_temperature + step,
            MIN_TEMP,
            MAX_TEMP
        )

        _last_temp_change = step
        _cycles_since_last_heatwave += 1
        _cycles_since_temp_change = 0

        if _current_temperature >= MAX_TEMP * 0.92 and _cycles_since_last_heatwave >= BETWEEN_HEATWAVE_DURATION:
            _state = State.PRE_HEATWAVE
    else: #Temperature stays the same for this cycle
        _last_temp_change = 0
        _cycles_since_last_heatwave += 1
        _cycles_since_temp_change += 1

## Increases temperature towards a heatwave
func _temp_advance_pre_heatwave() -> void:
    var random: float = randf()
    var chance_to_change: float = _cycles_since_temp_change * 0.25
    if random < chance_to_change:
        _current_temperature += 1
        _cycles_since_temp_change = 0
        _last_temp_change = 1
    else:
        _cycles_since_temp_change += 1
        _last_temp_change = 0
    
    if _current_temperature == MAX_TEMP:
        _cycles_since_last_heatwave = 0
        _state = State.HEATWAVE
    else:
        _cycles_since_last_heatwave += 1

## Mantain hight temperature during a heatwave
func _temp_advance_heatwave() -> void:
    _cycles_since_temp_change += 1
    _last_temp_change = 0
    
    if _cycles_since_temp_change > HEATWAVE_DURATION:
        _state = State.POST_HEATWAVE

## Lowers temperature after a heatwave
func _temp_advance_post_heatwave() -> void:
    var random: float = randf()
    var chance_to_change: float = _cycles_since_temp_change * 0.25
    if random < chance_to_change:
        _current_temperature -= 1
        _cycles_since_temp_change = 0
        _last_temp_change = -1
    else:
        _cycles_since_temp_change += 1
        _last_temp_change = 0

    if _current_temperature <= MAX_TEMP * 0.85:
        _state = State.NORMAL

## Gets the current world temperature
func get_current_temperature() -> int:
    return _current_temperature

## Returns a level representing the current temperature
func get_current_temperature_level() -> int:
    if _current_temperature < _temp_midpoint:
        return 0
    elif _current_temperature >= MAX_TEMP:
        return 2
    return 1