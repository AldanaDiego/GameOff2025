extends CanvasLayer
## Visual to cover the screen while changing scenes

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var _loading_label: Label = $LoadingLabel

var _timer: Timer
var _dot_counter: int

func _ready():
	_timer = GlobalTools.add_timer_node(self, 1)
	_timer.one_shot = false
	_timer.timeout.connect(_on_timer_timeout)
	_dot_counter = 0

## Shows a black screen for transitions
func fade_in() -> void:
	animation.play("dissolve")
	await animation.animation_finished

## Hides the transition black screen
func fade_out() -> void:
	animation.play_backwards("dissolve")

func set_loading_visible(is_loading_visible: bool) -> void:
	_loading_label.visible = is_loading_visible
	if is_loading_visible:
		_timer.start()
	else:
		_timer.stop()

func _on_timer_timeout() -> void:
	_dot_counter += 1
	if _dot_counter == 4:
		_dot_counter = 0
	_loading_label.text = tr("SCENE_TRANSITION_LOADING") + ".".repeat(_dot_counter)