class_name Stage extends Node3D
## Contains all the props for the game world

const MAP_WIDTH: int = 3
const MAP_HEIGHT: int = 3

@export var _chunk_prefab: PackedScene
@export var _wall_prefab: PackedScene
@export var _decoration_props: Array[PackedScene]

var _chunks: Array[Chunk]

signal on_stage_ready

func _ready() -> void:
	_chunks = []
	_decoration_props.shuffle()
	var k: int = 0
	for i in range(MAP_WIDTH):
		for j in range(MAP_HEIGHT):
			var pos: Vector3 = Vector3(
				(Chunk.SIZE * i) - (Chunk.SIZE * floori(MAP_WIDTH / 2.0)),
				0,
				(Chunk.SIZE * j) - (Chunk.SIZE * floori(MAP_HEIGHT / 2.0)),
			)
			
			if pos == Vector3.ZERO:
				continue

			var chunk: Chunk = _chunk_prefab.instantiate() as Chunk
			add_child(chunk)
			chunk.position = pos
			chunk.setup([_decoration_props[k]])
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
