extends Node2D

onready var pickups = get_node("Foreground/Game/Interactables/Pickups").get_children()
var levels
var level_index = 0
onready var game_scene = $Foreground/Game
onready var game_position

func _ready():
	yield(get_tree(), "idle_frame")
	game_position = game_scene.global_position
#	Globals.get_levels()
	levels = Globals.levels
	EventBus.connect("ready_to_proceed", self, "_on_next_level_ready")
	$Foreground/Game.connect("game_loaded", self, "_on_level_loaded")
	EventBus.emit_signal("pause")

func _on_level_loaded():
	pass

func _on_next_level_ready():
	level_index += 1
	if level_index >= levels.size():
		level_index = 0
	var next_level_scene = levels[level_index].instance()
	game_scene.disconnect("game_loaded", self, "_on_level_loaded")
	game_scene.queue_free()
	$Foreground.add_child(next_level_scene)
	next_level_scene.global_position = game_position
	next_level_scene.connect("game_loaded", self, "_on_level_loaded")
	game_scene = next_level_scene
	game_scene.set_owner(self)
	Globals.current_level = level_index

func _check_item_count():
	var non_deleted_pickups = []
	for pickup in pickups:
		if is_instance_valid(pickup):
			non_deleted_pickups.push_front(pickup)
	if non_deleted_pickups.size() == 0:
		level_index += 1
		var next_level = load(levels[level_index])
		game_scene.queue_free()
		add_child(next_level)
		next_level.global_position = game_position.global_position
#		Globals.next_level()
