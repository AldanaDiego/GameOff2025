extends CanvasLayer
## Visual to cover the screen while changing scenes

@onready var animation: AnimationPlayer = $AnimationPlayer

## Shows a black screen for transitions
func fade_in() -> void:
	animation.play("dissolve")
	await animation.animation_finished

## Hides the transition black screen
func fade_out() -> void:
	animation.play_backwards("dissolve")
