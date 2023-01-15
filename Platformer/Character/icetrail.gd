extends Line2D

export var length = 50
var point = Vector2(0,0)
export(NodePath) var target_path
var parent
var emitting = false


func _ready():
	parent = get_node(target_path) 


func _process(_delta):
	global_position = Vector2(0,0)
	# need way to only add points when player is grounded (emit a signal?)
	point = parent.global_position
	add_point(point)

	while get_point_count() > length:
		remove_point(0)
