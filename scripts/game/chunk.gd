class_name Chunk extends StaticBody3D
## Represents a portion of the stage map

const SIZE: float = 100.0
const WATER_SPOT_COUNT: int = 3
const HIDEOUT_COUNT: int = 1
const DISTANCE_BETWEEN_PROPS: float = 10.0

@export var _water_spot_prefab: PackedScene
@export var _hideout_prefab: PackedScene

var _hideouts: Array[Hideout]
var _water_spots: Array[WaterSpot]

func _ready() -> void:
    _hideouts = []
    _water_spots = []

## Inits this chunk. Spawns neccesary props 
func setup() -> void:
    #TODO add other props
    for i in range(HIDEOUT_COUNT):
        var hideout = _hideout_prefab.instantiate() as Hideout
        hideout.position = _generate_position()
        _hideouts.append(hideout)
        add_child(hideout)
    
    for i in range(WATER_SPOT_COUNT):
        var water_spot = _water_spot_prefab.instantiate() as WaterSpot
        water_spot.position = _generate_position()
        _water_spots.append(water_spot)
        add_child(water_spot)

## Generates a random position within the chunk to place a prop. It prevents positions too close to other props.
func _generate_position() -> Vector3:
    var pos: Vector3
    var is_valid_pos: bool = false

    while !is_valid_pos:
        pos = Vector3(
            randf_range(-SIZE/2, SIZE/2),
            0.0,
            randf_range(-SIZE/2, SIZE/2)
        )
        is_valid_pos = true
        for prop in _hideouts + _water_spots:
            if pos.distance_to(prop.position) < DISTANCE_BETWEEN_PROPS:
                is_valid_pos = false
                break

    return pos