extends Node2D

func _ready():
	EventBus.connect("pickup_entered_pipe", self, "_on_pickable_entered_pipe")
	$AnimationPlayer.play("RESET")
	
func _on_pickable_entered_pipe(type):
	spray_liquid(type)

func spray_liquid(type):
	$SpoutSprite.stretch(0.3, 1.0)
	match type:
		"coffee":
			print("playing spray_coffee")
			$AnimationPlayer.play("spray_coffee")
		"soda":
			print("playing spray_soda")
			$AnimationPlayer.play("spray_soda")
		"milk":
			print("playing spray_milk")
			$AnimationPlayer.play("spray_milk")
		"ice":
			print("restarting ice particles")
			$IceParticles.restart()
		_:
			print("doing nothing for type: " + type)
			
	yield(get_tree().create_timer(1), "timeout")
	$AnimationPlayer.play("RESET")
