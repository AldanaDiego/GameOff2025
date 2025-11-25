class_name WeatherUI extends Control

@export var _textures: Array[Texture]

@onready var _label: Label = $HBoxContainer/Label
@onready var _weather_texture: TextureRect = $HBoxContainer/WeatherTexture

var _current_texture: int

func _ready() -> void:
    _current_texture = 0
    _label.text = str(Weather.START_TEMP) + " C°"

func update(temp: int, temp_level: int) -> void:
    _label.text = str(temp) + " C°"
    if temp_level != _current_texture:
        _current_texture = temp_level
        _weather_texture.texture = _textures[temp_level]
