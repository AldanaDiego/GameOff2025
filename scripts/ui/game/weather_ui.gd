class_name WeatherUI extends Control

@export var _textures: Array[Texture]

@onready var _label: Label = $HBoxContainer/Label
@onready var _weather_texture: TextureRect = $HBoxContainer/WeatherTexture

var _current_texture: int
var _temp_midpoint: int

func _ready() -> void:
    _current_texture = 0
    _temp_midpoint = (Weather.MAX_TEMP + Weather.MIN_TEMP) / 2

func update(temp: int) -> void:
    _label.text = str(temp) + " C°"
    if temp < _temp_midpoint and _current_texture != 0:
        _current_texture = 0
        _weather_texture.texture = _textures[0]
    elif temp >= _temp_midpoint and temp < Weather.MAX_TEMP and _current_texture != 1:
        _current_texture = 1
        _weather_texture.texture = _textures[1]
    elif temp == Weather.MAX_TEMP and _current_texture != 2:
        _current_texture = 2
        _weather_texture.texture = _textures[2]

    
    
    
