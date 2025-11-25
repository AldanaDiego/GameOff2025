class_name Hideout extends Node3D
## Area where the player can hide from the sunlight

@onready var _area: Area3D = $Area3D

func _ready() -> void:
    _area.body_entered.connect(_on_body_entered)
    _area.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        (body as Player).set_current_hideout(self)

func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("Player"):
        (body as Player).set_current_hideout(null)
