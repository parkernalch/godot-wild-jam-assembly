extends Control

export(Array, String)var text_lines = []
onready var label: Label = $TextLabel

var active_index = -1
var is_fading = false

const FILE_NAME = "user://game-data.json"

func _ready():
	var file = File.new()
	if file.file_exists(FILE_NAME):
#		get_tree().change_scene_to(load("res://Scenes/GameWorld.tscn"))
		pass
	else:
		print("no saved data found")
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed():
		show_next()
	
func show_next():
	if is_fading:
		return
	active_index += 1
	if active_index < 0 or active_index > text_lines.size() - 1:
		yield(fade_out(), "completed")
		var file = File.new()
		file.open(FILE_NAME, File.WRITE)
		file.close()
		get_tree().change_scene_to(load("res://Scenes/GameWorld.tscn"))
		return
	is_fading = true
	if active_index > 0:
		yield(fade_out(), "completed")
	label.text = text_lines[active_index]
	yield(fade_in(), "completed")
	is_fading = false

func fade_out():
	yield(get_tree(), "idle_frame")
	if active_index == 0:
		return
	var process = 1
	while process >= 0:
		label.self_modulate = Color(1, 1, 1, process)
		process -= 0.05
		yield(get_tree().create_timer(0.005), "timeout")
	label.self_modulate = Color.transparent
	return

func fade_in():
	yield(get_tree(), "idle_frame")
	var process = 0
	while process <= 1:
		label.self_modulate = Color(1, 1, 1, process)
		process += 0.05
		yield(get_tree().create_timer(0.005), "timeout")
	label.self_modulate = Color.white
	return
