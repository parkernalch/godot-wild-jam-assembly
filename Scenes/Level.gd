extends Node2D

onready var pickups = get_node("Foreground/Game/Interactables/Pickups").get_children()

func _ready():
	Globals.get_levels()
	print(Globals.levels)

func _check_item_count():
	var non_deleted_pickups = []
	for pickup in pickups:
		if is_instance_valid(pickup):
			non_deleted_pickups.push_front(pickup)
	if non_deleted_pickups.size() == 0:
		Globals.next_level()

