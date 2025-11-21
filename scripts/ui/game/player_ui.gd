class_name PlayerUI extends Control

@onready var _water_ui: TextureProgressBar = $HBoxContainer/WaterTank/WaterBar
@onready var _temperature_ui: TextureProgressBar = $HBoxContainer/Thermometer/TemperatureBar

var _last_water: float
var _target_water: float
var _last_temp: float
var _target_temp: float
var _acc_delta: float

func _ready() -> void:
    _water_ui.value = 100.0
    _last_water = 100.0
    _target_water = 100.0
    _temperature_ui.value = 0.0
    _last_temp = 0.0
    _target_temp = 0.0

func _process(delta) -> void:
    _acc_delta = min (_acc_delta + delta, Game.TICK)
    _water_ui.value = lerp(_last_water, _target_water, _acc_delta / Game.TICK)
    _temperature_ui.value = lerp(_last_temp, _target_temp, _acc_delta / Game.TICK)

## Update the progress bars on this UI
func update(water: float, temperature: float) -> void:
    _last_water = _water_ui.value
    _target_water = water
    _last_temp = _temperature_ui.value
    _target_temp = temperature
    _acc_delta = 0.0