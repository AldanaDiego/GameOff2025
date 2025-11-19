class_name Stage extends Node3D
## Contains all the props for the game world

const MAP_WIDTH: int = 3
const MAP_HEIGHT: int = 3

@export var _chunk_prefab: PackedScene
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

	on_stage_ready.emit()

## For each [class Chunk] reveal diggable spots that are at a certain distance from [param pos]
func reveal_diggable_spots(pos: Vector3) -> void:
	for chunk in _chunks:
		chunk.reveal_diggable_spots(pos)
