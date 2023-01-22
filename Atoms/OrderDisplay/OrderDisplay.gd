extends Control

onready var items = get_node("VBoxContainer/HBoxContainer").get_children()
export(NodePath) var pickups
onready var pickup_children = get_node(pickups).get_children()

export(Texture) var soda_sprite
export(Texture) var coffee_sprite
export(Texture) var ice_sprite
export(Texture) var milk_sprite

var sprite_lookup

func _ready():
	sprite_lookup = {
		"soda" : soda_sprite,
		"ice": ice_sprite,
		"coffee": coffee_sprite,
		"milk": milk_sprite
	}
	yield(get_tree(), "idle_frame")
	for pickup in pickup_children:
		var new_rect = TextureRect.new()
#		print("looked up " + str(pickup.pickup_type) + " and found " + str(sprite_lookup[pickup.pickup_type]))
		new_rect.texture = sprite_lookup[pickup.pickup_type]
#		print("Texture: " + str(new_rect.texture))
		$VBoxContainer/HBoxContainer.add_child(new_rect)
		new_rect.visible = true
	
func _on_pickup(type):
	for item in $VBoxContainer/HBoxContainer.get_children():
		if item.texture == sprite_lookup[type]:
			item.queue_free()
			return
