class_name Stage extends Node3D
## Contains all the props for the game world

const MAP_WIDTH: int = 3
const MAP_HEIGHT: int = 3
const DECORATIONS_PER_CHUNK: int = 3

@export var _chunk_prefab: PackedScene
@export var _wall_prefab: PackedScene
@export var _decoration_props: Array[PackedScene]

var _chunks: Array[Chunk]

signal on_stage_ready

func _ready() -> void:
	_chunks = []
	var decorations_to_add = []
	var decorations_shuffle = []
	## Bro trust me this gonna work xd
	decorations_shuffle.resize(DECORATIONS_PER_CHUNK * MAP_WIDTH * MAP_HEIGHT)
	for i in range(decorations_shuffle.size()):
		decorations_shuffle[i] = i % _decoration_props.size()
	decorations_shuffle.shuffle()

	decorations_to_add.resize(MAP_WIDTH * MAP_HEIGHT)
	for i in range(decorations_to_add.size()):
		decorations_to_add[i] = []
		for j in range(DECORATIONS_PER_CHUNK):
			decorations_to_add[i].append(_decoration_props[decorations_shuffle[(i * DECORATIONS_PER_CHUNK) + j]])

	print_debug(decorations_to_add)

	var k: int = 0
	for i in range(MAP_WIDTH):
		for j in range(MAP_HEIGHT):
			var pos: Vector3 = Vector3(
				(Chunk.SIZE * i) - (Chunk.SIZE * floori(MAP_WIDTH / 2.0)),
				0,
				(Chunk.SIZE * j) - (Chunk.SIZE * floori(MAP_HEIGHT / 2.0)),
			)

			var chunk: Chunk = _chunk_prefab.instantiate() as Chunk
			add_child(chunk)
			chunk.position = pos
			chunk.setup(decorations_to_add[k], (pos == Vector3.ZERO))
			k += 1
			_chunks.append(chunk)

			if i == 0:
				_spawn_wall(pos + Vector3((-Chunk.SIZE / 2) - 2.5, 0, 0), true)
			elif i == MAP_WIDTH - 1:
				_spawn_wall(pos + Vector3((Chunk.SIZE / 2) + 2.5, 0, 0), true)
			if j == 0:
				_spawn_wall(pos + Vector3(0, 0, (-Chunk.SIZE / 2) - 2.5), false)
			elif j == MAP_HEIGHT - 1:
				_spawn_wall(pos + Vector3(0, 0, (Chunk.SIZE / 2) + 2.5), false)

	on_stage_ready.emit()

func _spawn_wall(pos: Vector3, is_rotated: bool) -> void:
	var wall = _wall_prefab.instantiate() as Node3D
	wall.position = pos
	wall.rotation_degrees.y = 90 if is_rotated else 0
	add_child(wall)

## For each [class Chunk] reveal diggable spots that are at a certain distance from [param pos]
func reveal_diggable_spots(pos: Vector3) -> void:
	for chunk in _chunks:
		chunk.reveal_diggable_spots(pos)
