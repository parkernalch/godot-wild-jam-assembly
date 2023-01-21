extends Control

onready var items = get_node("VBoxContainer/HBoxContainer").get_children()

func _on_pickup(type):
	for item in items:
		if item.name == type:
			item.visible = false
