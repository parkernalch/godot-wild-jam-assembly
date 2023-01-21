extends Control

onready var items = get_node("VBoxContainer/HBoxContainer").get_children()
export(NodePath) var pickups
onready var pickup_children = get_node(pickups).get_children()

func _ready():
	for item in items:
		item.visible = false
	for pickup in pickup_children:
		for item in items:
			if item.name == pickup.pickup_type:
				item.visible = true 
	
func _on_pickup(type):
	for item in items:
		if item.name == type:
			item.visible = false
