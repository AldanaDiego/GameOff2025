class_name TreasureSpot extends Node3D
## Area where player can dig for treasure

const EXTRACT_DURATION: float = 5.0
const QUEUE_FREE_DELAY: float = 2.1

enum State { HIDDEN, VISIBLE, EXTRACTING, EMPTY }

@onready var _area: Area3D = $Area3D
@onready var _wave_vfx: GPUParticles3D = $WaveParticles
@onready var _sparkle_vfx: GPUParticles3D = $SparkleParticles
@onready var _gem: MeshInstance3D = $Gem

var _state: State
var _extract_timer: Timer
var _queue_free_timer: Timer
var _is_player_inside: float

signal ready_to_delete(TreasureSpot)

func _ready() -> void:
	_area.body_entered.connect(_on_body_entered)
	_area.body_exited.connect(_on_body_exited)
	_state = State.HIDDEN
	_extract_timer = GlobalTools.add_timer_node(self, EXTRACT_DURATION)
	_extract_timer.timeout.connect(_on_extraction_finished)
	_queue_free_timer = GlobalTools.add_timer_node(self, QUEUE_FREE_DELAY)
	_is_player_inside = false

## Called when Player digs on this area
func extract() -> void:
	_state = State.EXTRACTING
	_sparkle_vfx.emitting = false
	var tween: Tween = create_tween()
	tween.tween_property(_gem, "position:y", 3, 2).set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	_extract_timer.start()

## Shows VFX for the player to find this area
func reveal() -> void:
	_state = State.VISIBLE
	_wave_vfx.emitting = true
	_sparkle_vfx.emitting = true

func get_state() -> State:
	return _state

func preview_vfx() -> void:
	_wave_vfx.emitting = true
	_sparkle_vfx.emitting = true

	var timer = GlobalTools.add_timer_node(self, 1)
	timer.start()
	await timer.timeout

	_wave_vfx.emitting = false
	_sparkle_vfx.emitting = false

	timer.queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and _state != State.EMPTY:
		_is_player_inside = true
		(body as Player).set_current_treasure_spot(self)
		if _state == State.VISIBLE:
			_sparkle_vfx.emitting = false

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		_is_player_inside = false
		(body as Player).set_current_treasure_spot(null)
		if _state == State.VISIBLE:
			_sparkle_vfx.emitting = true
		elif _state == State.EMPTY:
			_queue_free_timer.start()
			await _queue_free_timer.timeout
			ready_to_delete.emit(self)

func _on_extraction_finished() -> void:
	_state = State.EMPTY
	_wave_vfx.emitting = false
	if !_is_player_inside:
		_queue_free_timer.start()
		await _queue_free_timer.timeout
		ready_to_delete.emit(self)