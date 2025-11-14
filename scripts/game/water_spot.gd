class_name WaterSpot extends Node3D
## Area where player can dig to find water

@onready var _area: Area3D = $Area3D

func _ready() -> void:
    _area.body_entered.connect(_on_body_entered)
    _area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        pass #TODO water area monitor player

func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("Player"):
        pass #TODO water area monitor player