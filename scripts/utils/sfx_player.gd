class_name SfxPlayer extends AudioStreamPlayer3D
## Audio stream player for SFX. Will randomize pitch.

var _last_pitch: Dictionary

func _ready() -> void:
	_last_pitch = {}

## Plays a sound effect with random pitch
func play_sfx(sound: AudioStream, db: float = 0) -> void:
	var pitch: float = randf_range(0.85, 1.15)
	if _last_pitch.has(sound):
		while (abs(pitch - _last_pitch[sound]) < 0.1):
			pitch = randf_range(0.85, 1.15)
	else:
		pitch = 1.0
		_last_pitch[sound] = 1.0

	stream = sound
	volume_db = db
	pitch_scale = pitch
	_last_pitch[sound] = pitch
	play()

