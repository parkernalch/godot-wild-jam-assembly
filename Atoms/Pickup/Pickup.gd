extends Area2D

var picked_up_scene = preload("res://Atoms/PickedUp/PickedUp.tscn")
export var pickup_sprite: Texture

func _ready():
	$Sprite.texture = pickup_sprite
	connect("body_entered", self, "_on_body_entered")
	pass
	
func _on_body_entered(body):
	if body is Player:
		pickup()
	pass
	
func pickup():
	var picked_up_instance = picked_up_scene.instance()
	picked_up_instance.global_position = global_position
	get_parent().add_child(picked_up_instance)
	picked_up_instance.texture = pickup_sprite
	picked_up_instance.collect(Vector2(1000, 1000))
	yield(get_tree(), "idle_frame")
	queue_free()
	pass
