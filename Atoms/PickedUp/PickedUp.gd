extends Sprite

var target_pos = Vector2.ZERO
var path: Path2D

var time_elapsed = 0
var reflect = false

func _ready():
	path = Path2D.new()
	add_child(path)
	path.curve = Curve2D.new()
	set_process(false)
	reflect = randi() % 2 == 0
	pass
	
func collect(new_target):
	target_pos = new_target
	path.curve.add_point(global_position, Vector2.ZERO, Vector2(300, -300) * Vector2(-1 if reflect else 1, 1))
	path.curve.add_point(target_pos, Vector2(0, -300), Vector2.ZERO)
	set_process(true)
	pass
	
func _process(delta):
	if time_elapsed >= 1.0:
		queue_free()
	global_position = path.curve.interpolate(0, time_elapsed)
	time_elapsed += delta
	pass
	


