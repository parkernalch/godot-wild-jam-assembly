extends Node

var current_level = -1
var pipe_location = Vector2.ZERO

var levels = []

func get_levels():
	if levels.size() >= 1:
		return
	var path = "Scenes/Levels/"
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			#break the while loop when get_next() returns ""
			break
		elif ".tscn" in file_name:
			levels.append(path + file_name)
	dir.list_dir_end()
	levels.sort()
	print(levels)
	
func next_level():
	current_level += 1
	if current_level >= levels.size() - 1:
		return
	get_tree().change_scene(levels[current_level])
