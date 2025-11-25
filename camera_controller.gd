extends Camera2D

const FOLLOW_SPEED = 5.0
const LOOK_AHEAD = 100.0

var target: Node2D = null
var min_x = -1000
var max_x = 5000
var min_y = -1000
var max_y = 2000

func _ready():
	limit_left = min_x
	limit_right = max_x
	limit_top = min_y
	limit_bottom = max_y
	smoothing_enabled = true
	smoothing_speed = FOLLOW_SPEED

func _process(delta):
	if target:
		var target_pos = target.global_position
		global_position = global_position.lerp(target_pos, delta * FOLLOW_SPEED)

func set_target(new_target: Node2D):
	target = new_target
