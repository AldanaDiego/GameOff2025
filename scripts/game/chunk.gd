class_name Chunk extends StaticBody3D
## Represents a portion of the stage map

const SIZE: float = 100.0
const WATER_SPOT_COUNT: int = 3
const HIDEOUT_COUNT: int = 1
const DISTANCE_BETWEEN_PROPS: float = 20.0
const GENERATE_POSITION_OFFSET: float = 10.0

@export var _water_spot_prefab: PackedScene
@export var _hideout_prefab: PackedScene
@export var _start_pad_prefab: PackedScene
@export var _treasure_spot_prefab: PackedScene

var _hideouts: Array[Hideout]
var _water_spots: Array[WaterSpot]
var _treasure_spots: Array[TreasureSpot]
var _props: Array[Node3D]

signal on_treasure_found

func _ready() -> void:
	_hideouts = []
	_water_spots = []
	_treasure_spots = []
	_props = []

## Inits this chunk. Spawns neccesary props 
func setup(props: Array, is_center_chunk: bool, has_treasure: bool) -> void:
	if is_center_chunk:
		var pad = _start_pad_prefab.instantiate()
		pad.position = Vector3.ZERO
		_props.append(pad)
		add_child(pad)
	else:
		for i in range(HIDEOUT_COUNT):
			var hideout = _hideout_prefab.instantiate() as Hideout
			if i == 0:
				hideout.position = Vector3.ZERO
			else:
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
		_props.append(prop)
		add_child(prop)

	if has_treasure:
		var treasure_spot = _treasure_spot_prefab.instantiate() as TreasureSpot
		treasure_spot.position = _generate_position()
		treasure_spot.ready_to_delete.connect(_on_treasure_spot_delete)
		_treasure_spots.append(treasure_spot)
		add_child(treasure_spot)

## Reveal diggable spots that are at a certain distance from [param pos]
func reveal_diggable_spots(pos: Vector3) -> void:
	var distance_to_chunk: float = pos.distance_to(self.global_position)
	if distance_to_chunk <= SIZE + GlobalConstants.PLAYER_RADAR_DISTANCE:
		for water_spot in _water_spots:
			var distance: float = water_spot.global_position.distance_to(pos)
			if distance <= GlobalConstants.PLAYER_RADAR_DISTANCE:
				water_spot.reveal()

		for treasure_spot in _treasure_spots:
			var distance: float = treasure_spot.global_position.distance_to(pos)
			if distance <= GlobalConstants.PLAYER_RADAR_DISTANCE:
				treasure_spot.reveal()

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
		for prop in _hideouts + _water_spots + _props:
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

## Deletes a treasure spot after its been digged
func _on_treasure_spot_delete(spot: TreasureSpot) -> void:
	var index: int = _treasure_spots.find(spot)
	_treasure_spots[index].ready_to_delete.disconnect(_on_treasure_spot_delete)
	_treasure_spots[index].queue_free()
	_treasure_spots.remove_at(index)
	on_treasure_found.emit()
