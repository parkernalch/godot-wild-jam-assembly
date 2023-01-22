extends Node2D

var pickups = []
#signal ready_to_proceed()
signal game_loaded()

func _ready():
	yield(get_tree(), "idle_frame")
	pickups = $Interactables/Pickups.get_children()
	$Interactables/FinishPipe.connect("check_item_count", self, "_on_check_item_count")
	Globals.pipe_location = $Interactables/FinishPipe.global_position
	for pickup in pickups:
		pickup.connect("picked_up", self, "_on_pickup_picked_up")
	emit_signal("game_loaded")
	pass

func _on_check_item_count():
	if pickups.size() == 0:
		EventBus.emit_signal("ready_to_proceed")

func _on_pickup_picked_up(type):
	for pickup_instance in pickups:
		if pickup_instance.pickup_type == type:
			pickup_instance.disconnect("picked_up", self, "_on_pickup_picked_up")
			pickups.remove(pickups.find(pickup_instance))
			break
		pass
