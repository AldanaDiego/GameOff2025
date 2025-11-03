class_name MusicManager extends Node
## Manages the _music in the game

@onready var _music: AudioStreamPlayer = $Music

var _timer: Timer

func _ready() -> void:
	_timer = GlobalTools.add_timer_node(self)

## Sets volume to specific volume. Should be used only in the [method MusicManager.fade_in] and [method MusicManager.fade_out] methods.
func _set_volume(vol: float) -> void:
	_music.volume_db = linear_to_db(vol)

## Starts the _music
func play() -> void:
	_music.play()

## Stops the _music
func stop() -> void:
	_music.stop()

## Gradually increases _music volume during [param time] seconds
func fade_in(time: float, delay: float = 0) -> void:
	#For some reason tween.set_delay doesn't work here, so we wait with timer
	if delay > 0:
		_timer.wait_time = delay
		_timer.start()
		await _timer.timeout
	var tween = create_tween()
	_set_volume(0.01)
	play()
	tween.tween_method(_set_volume, 0.01, 1.0, time)

## Gradually decreases _music volume during [param time] seconds
func fade_out(time: float, delay: float = 0) -> void:
	var tween = create_tween()
	_set_volume(1)
	tween.tween_method(_set_volume, 1.0, 0.01, time).set_delay(delay)
	await tween.finished
	stop()

## Changes the currently playing [class AudioStream]
func set_stream(song: AudioStream) -> void:
	_music.stream = song

## Gradually decrease music volume to half volume during [param time] seconds
func muffle(time: float) -> void:
	var tween = create_tween()
	_set_volume(1)
	tween.tween_method(_set_volume, 1.0, 0.5, time)

## Gradually increase music volume from half volume during [param time] seconds
func unmuffle(time: float) -> void:
	var tween = create_tween()
	_set_volume(0.5)
	tween.tween_method(_set_volume, 0.5, 1, time)
