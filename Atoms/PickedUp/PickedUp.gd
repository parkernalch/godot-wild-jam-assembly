extends Sprite

var path: Path2D

var time_elapsed = 0
var reflect = false

var pickup_type = ""

func _ready():
	path = Path2D.new()
	add_child(path)
	path.curve = Curve2D.new()
	set_process(false)
	reflect = randi() % 2 == 0
	pass
	
func collect(type):
	pickup_type = type
	path.curve.add_point(global_position, Vector2.ZERO, Vector2(300, -300) * Vector2(-1 if reflect else 1, 1))
	path.curve.add_point(Globals.pipe_location, Vector2(0, -300), Vector2.ZERO)
	set_process(true)
	pass
	
func _process(delta):
	if time_elapsed >= 1.0:
		EventBus.emit_signal("pickup_entered_pipe", pickup_type)
		queue_free()
	global_position = path.curve.interpolate(0, time_elapsed)
	time_elapsed += delta * 1.3
	pass
	



