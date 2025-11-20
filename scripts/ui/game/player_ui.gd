class_name PlayerUI extends Control

@onready var _water_ui: TextureProgressBar = $HBoxContainer/WaterTank/WaterBar
@onready var _temperature_ui: TextureProgressBar = $HBoxContainer/Thermometer/TemperatureBar

func _ready() -> void:
    _water_ui.value = 100.0
    _temperature_ui.value = 0.0

## Update the progress bars on this UI
func update(water: float, temperature: float) -> void:
    _water_ui.value = water
    _temperature_ui.value = temperature