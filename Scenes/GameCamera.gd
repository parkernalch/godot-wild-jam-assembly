extends Camera2D

export var in_game_offset: Vector2
export var in_game_zoom: Vector2

var is_zoomed_in = false

func _ready():
	pass
	
func toggle_zoom():
	if is_zoomed_in:
		smooth_zoom(Vector2.ZERO, Vector2(1, 1), 0.05)
		is_zoomed_in = false
	else:
		smooth_zoom(in_game_offset, in_game_zoom, 0.05)
		is_zoomed_in = true

func smooth_zoom(target_offset, target_zoom, duration):
	var t = 0
	var i_zoom = zoom
	var i_offset = offset
	while t < duration:
		yield(get_tree().create_timer(0.01), "timeout")
		zoom = lerp(i_zoom, target_zoom, t / duration)
		offset = lerp(i_offset, target_offset, t / duration)
		t += 0.01
	zoom = target_zoom
	offset = target_offset

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_pressed() and event.scancode == KEY_ESCAPE:
			toggle_zoom()
