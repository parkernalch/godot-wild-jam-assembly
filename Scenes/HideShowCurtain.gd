extends Control

onready var left_curtain = $LeftRect
onready var right_curtain = $RightRect

var is_animating = false
var is_closed = true

var step = 50
var width

func _ready():
	width = margin_right - margin_left
	pass
	
func _input(event):
	if event.is_pressed() and event is InputEventKey:
		if event.scancode == KEY_ESCAPE:
			toggle()
	
func toggle():
	if is_animating:
		return
	is_animating = true
	if is_closed:
		EventBus.emit_signal("resume")
		yield(open_curtains(), "completed")
	else:
		EventBus.emit_signal("pause")
		yield(draw_curtains(), "completed")
	is_animating = false
	
func draw_curtains():
	yield(get_tree(), "idle_frame")
	var opacity_step = width / 2 / step
	var opacity = 0
	while left_curtain.margin_right < width / 2:
		left_curtain.margin_right += step
		right_curtain.margin_left -= step
		$Title.modulate = Color(1, 1, 1, opacity)
		opacity += opacity_step
		yield(get_tree().create_timer(0.01), "timeout")
	left_curtain.margin_right = width / 2
	right_curtain.margin_left = -width / 2
	$Title.modulate = Color.white
	is_closed = true
	return

func open_curtains():
	yield(get_tree(), "idle_frame")
	var opacity_step = width / 2 / step
	var opacity = 1
	while left_curtain.margin_right > 0:
		left_curtain.margin_right -= step
		right_curtain.margin_left += step
		$Title.modulate = Color(1, 1, 1, opacity)
		opacity -= opacity_step
		yield(get_tree().create_timer(0.01), "timeout")
	left_curtain.margin_right = 0
	right_curtain.margin_left = 0
	$Title.modulate = Color.transparent
	is_closed = false
	return

