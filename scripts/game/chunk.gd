class_name Chunk extends StaticBody3D
## Represents a portion of the stage map

const SIZE: float = 100.0
const WATER_SPOT_COUNT: int = 3
const HIDEOUT_COUNT: int = 1
const DISTANCE_BETWEEN_PROPS: float = 20.0
const GENERATE_POSITION_OFFSET: float = 10.0

@export var _water_spot_prefab: PackedScene
@export var _hideout_prefab: PackedScene

var _hideouts: Array[Hideout]
var _water_spots: Array[WaterSpot]

func _ready() -> void:
	_hideouts = []
	_water_spots = []

## Inits this chunk. Spawns neccesary props 
func setup(props: Array[PackedScene]) -> void:
	for i in range(HIDEOUT_COUNT):
		var hideout = _hideout_prefab.instantiate() as Hideout
		hideout.position = _generate_position()
		_hideouts.append(hideout)
		add_child(hideout)

	for i in range(WATER_SPOT_COUNT):
		var water_spot = _water_spot_prefab.instantiate() as WaterSpot
		water_spot.position = _generate_position()
		water_spot.ready_to_delete.connect(_on_water_spot_delete)
		_water_spots.append(water_spot)
		add_child(water_spot)

	for prop_prefab in props:
		var prop = prop_prefab.instantiate() as Node3D
		prop.position = _generate_position()
		prop.rotation_degrees.y = randf_range(0, 360)
		add_child(prop)

	#TODO add other diggable spots

## Reveal diggable spots that are at a certain distance from [param pos]
func reveal_diggable_spots(pos: Vector3) -> void:
	var distance_to_chunk: float = pos.distance_to(self.global_position)
	if distance_to_chunk <= SIZE + GlobalConstants.PLAYER_RADAR_DISTANCE:
		for water_spot in _water_spots:
			var distance: float = water_spot.global_position.distance_to(pos)
			if distance <= GlobalConstants.PLAYER_RADAR_DISTANCE:
				water_spot.reveal()

	#TODO add other diggable spots

## Generates a random position within the chunk to place a prop. It prevents positions too close to other props.
func _generate_position() -> Vector3:
	var pos: Vector3
	var is_valid_pos: bool = false

	while !is_valid_pos:
		pos = Vector3(
			randf_range(-SIZE/2 + GENERATE_POSITION_OFFSET, SIZE/2 - GENERATE_POSITION_OFFSET),
			0.0,
			randf_range(-SIZE/2 + GENERATE_POSITION_OFFSET, SIZE/2 - GENERATE_POSITION_OFFSET)
		)
		is_valid_pos = true
		for prop in _hideouts + _water_spots:
			if pos.distance_to(prop.position) < DISTANCE_BETWEEN_PROPS:
				is_valid_pos = false
				break

	return pos

## When a [class WaterSpot] is empty, delete and create a new one
func _on_water_spot_delete(spot: WaterSpot) -> void:
	var index: int = _water_spots.find(spot)
	var pos: Vector3 = _generate_position()

	_water_spots[index].ready_to_delete.disconnect(_on_water_spot_delete)
	_water_spots[index].queue_free()

	var new_spot = _water_spot_prefab.instantiate() as WaterSpot
	new_spot.position = pos
	new_spot.ready_to_delete.connect(_on_water_spot_delete)
	_water_spots[index] = new_spot
	add_child(new_spot)
