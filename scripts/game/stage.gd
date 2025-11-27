class_name Stage extends Node3D
## Contains all the props for the game world

const MAP_WIDTH: int = 3
const MAP_HEIGHT: int = 3
const DECORATIONS_PER_CHUNK: int = 3
const TREASURE_COUNT: int = 3

@export var _chunk_prefab: PackedScene
@export var _wall_prefab: PackedScene
@export var _decoration_props: Array[PackedScene]

var _chunks: Array[Chunk]
var _treasures_found: int

signal on_stage_ready
signal on_all_treasures_found

#region Setup and process

func _ready() -> void:
	_chunks = []
	_treasures_found = 0
	var decorations_to_add = _shuffle_decorations()
	var chunks_with_treasure = _shuffle_treasure()

	var k: int = 0
	for i in range(MAP_WIDTH):
		for j in range(MAP_HEIGHT):
			var pos: Vector3 = Vector3(
				(Chunk.SIZE * i) - (Chunk.SIZE * floori(MAP_WIDTH / 2.0)),
				0,
				(Chunk.SIZE * j) - (Chunk.SIZE * floori(MAP_HEIGHT / 2.0)),
			)

			var has_treasure: bool = chunks_with_treasure.find(i * MAP_WIDTH + j) != -1
			_spawn_chunk(pos, decorations_to_add[k], has_treasure)
			k += 1

			if i == 0:
				_spawn_wall(pos + Vector3((-Chunk.SIZE / 2) - 2.5, 0, 0), true)
			elif i == MAP_WIDTH - 1:
				_spawn_wall(pos + Vector3((Chunk.SIZE / 2) + 2.5, 0, 0), true)
			if j == 0:
				_spawn_wall(pos + Vector3(0, 0, (-Chunk.SIZE / 2) - 2.5), false)
			elif j == MAP_HEIGHT - 1:
				_spawn_wall(pos + Vector3(0, 0, (Chunk.SIZE / 2) + 2.5), false)

	on_stage_ready.emit()

#endregion

#region Public functions

## For each [class Chunk] reveal diggable spots that are at a certain distance from [param pos]
func reveal_diggable_spots(pos: Vector3) -> void:
	for chunk in _chunks:
		chunk.reveal_diggable_spots(pos)

## Plays vfx on the stage
func preview_vfx() -> void:
	for chunk in _chunks:
		chunk.preview_vfx()

#endregion

#region Private functions

## Creates a new chunk
func _spawn_chunk(pos: Vector3, props: Array, has_treasure: bool) -> void:
	var chunk: Chunk = _chunk_prefab.instantiate() as Chunk
	add_child(chunk)
	chunk.position = pos
	chunk.setup(props, (pos == Vector3.ZERO), has_treasure)
	chunk.on_treasure_found.connect(_on_chunk_treasure_found)
	_chunks.append(chunk)

## Adds a wall to a chunk at the borders
func _spawn_wall(pos: Vector3, is_rotated: bool) -> void:
	var wall = _wall_prefab.instantiate() as Node3D
	wall.position = pos
	wall.rotation_degrees.y = 90 if is_rotated else 0
	add_child(wall)

## Returns an array with props to add to each chunk
func _shuffle_decorations() -> Array:
	var decorations_to_add = []
	var decorations_shuffle = []
	## Bro trust me this works xd
	decorations_shuffle.resize(DECORATIONS_PER_CHUNK * MAP_WIDTH * MAP_HEIGHT)
	for i in range(decorations_shuffle.size()):
		decorations_shuffle[i] = i % _decoration_props.size()
	decorations_shuffle.shuffle()

	decorations_to_add.resize(MAP_WIDTH * MAP_HEIGHT)
	for i in range(decorations_to_add.size()):
		decorations_to_add[i] = []
		for j in range(DECORATIONS_PER_CHUNK):
			decorations_to_add[i].append(_decoration_props[decorations_shuffle[(i * DECORATIONS_PER_CHUNK) + j]])

	return decorations_to_add

## Returns an array of indexes for assigning treasures to certain chunks
func _shuffle_treasure() -> Array:
	var chunks_with_treasure = []
	for i in range(TREASURE_COUNT):
		var is_valid: bool = false
		while !is_valid:
			var chunk_id = randi_range(0, MAP_WIDTH * MAP_HEIGHT - 1)
			if chunks_with_treasure.find(chunk_id) == -1:
				chunks_with_treasure.append(chunk_id)
				is_valid = true

	return chunks_with_treasure

#endregion

#region Signal connects

## Listens to a treasure found by player. Decreases counter and checks for game over
func _on_chunk_treasure_found() -> void:
	_treasures_found += 1
	if _treasures_found >= TREASURE_COUNT:
		on_all_treasures_found.emit()

#endregion
