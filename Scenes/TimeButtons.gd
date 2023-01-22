extends VBoxContainer

var buttons = []
var button_theme = preload("res://Resources/button_theme.tres")

func _ready():
	EventBus.connect("save_data_loaded", self, "populate_children")
	pass
	
func populate_children(level_data):
	print("got level data")
	for button in get_children():
		button.queue_free()
	for level in level_data.levels:
		var button = Button.new()
		button.text = '\n'
		button.text = "Name: " + str(level.name) +  " | Best: " + str(level.best_time) + " - Last: " + str(level.last_time)
		button.theme = button_theme
		if level.best_time == level.last_time:
			button.self_modulate = Color.green
		add_child(button)
	pass
	
	
