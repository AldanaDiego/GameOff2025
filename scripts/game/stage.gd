class_name Stage extends Node3D
## Contains all the props for the game world

const MAP_WIDTH: int = 3
const MAP_HEIGHT: int = 3
const CHUNK_SIZE: int = 100

@export var _chunk_prefab: PackedScene

var _chunks: Array[Chunk]

signal on_stage_ready

func _ready() -> void:
	_chunks = []
	for i in range(MAP_WIDTH):
		for j in range(MAP_HEIGHT):
			var pos: Vector3 = Vector3(
				(CHUNK_SIZE * i) - (CHUNK_SIZE * floori(MAP_WIDTH / 2.0)),
				0,
				(CHUNK_SIZE * j) - (CHUNK_SIZE * floori(MAP_HEIGHT / 2.0)),
			)
			
			if pos == Vector3.ZERO:
				continue

			var chunk: Chunk = _chunk_prefab.instantiate() as Chunk
			chunk.position = pos
			chunk.setup()
			_chunks.append(chunk)
			add_child(chunk)

	on_stage_ready.emit()
