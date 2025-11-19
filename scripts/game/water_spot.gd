class_name WaterSpot extends Node3D
## Area where player can dig to find water

@onready var _area: Area3D = $Area3D
@onready var _wave_vfx: GPUParticles3D = $WaveParticles
@onready var _sparkle_vfx: GPUParticles3D = $SparkleParticles

func _ready() -> void:
    _area.body_entered.connect(_on_body_entered)
    _area.body_exited.connect(_on_body_exited)

## Called when Player digs on this area
func extract() -> void:
    pass #TODO

## Shows VFX for the player to find this area
func reveal() -> void:
    _wave_vfx.emitting = true
    _sparkle_vfx.emitting = true

func _on_body_entered(body: Node3D) -> void:
    if body.is_in_group("Player"):
        (body as Player).set_current_water_spot(self)

func _on_body_exited(body: Node3D) -> void:
    if body.is_in_group("Player"):
        (body as Player).set_current_water_spot(null)