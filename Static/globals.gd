extends Node

var current_level = 0
var pipe_location = Vector2.ZERO

var levels = [
	preload("res://Scenes/Levels/Level00.tscn"),
	preload("res://Scenes/Levels/Level01.tscn"),
	preload("res://Scenes/Levels/Level02.tscn"),
	preload("res://Scenes/Levels/Level03.tscn"),
	preload("res://Scenes/Levels/Level04.tscn"),
	preload("res://Scenes/Levels/Level05.tscn"),
	preload("res://Scenes/Levels/Level06.tscn"),
	preload("res://Scenes/Levels/Level07.tscn"),
	preload("res://Scenes/Levels/Level08.tscn"),
	preload("res://Scenes/Levels/Level09.tscn"),
	preload("res://Scenes/Levels/Level10.tscn")
]

var level_data = {
	"levels": [
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 0"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 1"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 2"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 3"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 4"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 5"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 6"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 7"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 8"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 9"
		},
		{
			"best_time": 9999,
			"last_time": 0,
			"name": "Level 10"
		}
	]
}

func _ready():
	var file = File.new()
	if file.file_exists("user://level_data.json"):
		file.open("user://level_data.json", File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			level_data = data
			print("emitting level data")
			yield(get_tree(), "idle_frame")
			EventBus.emit_signal("save_data_loaded", level_data)

func set_current_stage_time(time):
	var current = level_data.levels[current_level - 1]
	if current.best_time < time:
		current.last_time = time
	else:
		current.last_time = time
		current.best_time = time
	var file = File.new()
	file.open("user://level_data.json", File.WRITE)
	file.store_string(to_json(level_data))
	file.close()
	EventBus.emit_signal("save_data_loaded", level_data)
	print(current)

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
	print(current_level)
	if current_level >= levels.size() - 1:
		return
	get_tree().change_scene(levels[current_level])
