class_name WeatherUI extends Control

@export var _textures: Array[Texture]

@onready var _label: Label = $HBoxContainer/Label
@onready var _weather_texture: TextureRect = $HBoxContainer/WeatherTexture

var _current_texture: int

func _ready() -> void:
    _current_texture = 0
    _set_label_text(Weather.START_TEMP)

func update(temp: int, temp_level: int) -> void:
    _set_label_text(temp)
    if temp_level != _current_texture:
        _current_texture = temp_level
        _weather_texture.texture = _textures[temp_level]

func _set_label_text(temp: int) -> void:
    if Settings.get_setting_value("General", "TempDisplay") == GlobalConstants.TempDisplay.CELCIUS:
        _label.text = str(temp) + " C°"
    else:
        var fht: float = snappedf((temp * 9/5.0) + 32, 0.1)
        _label.text = str(fht) + " F°"