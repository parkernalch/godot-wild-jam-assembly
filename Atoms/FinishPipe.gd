extends StaticBody2D

onready var player_detector: Area2D = $EntryArea
onready var particles: CPUParticles2D = $CPUParticles2D

func _ready():
	player_detector.connect("body_entered", self, "_on_player_entered")
	Globals.pipe_location = global_position
	EventBus.connect("pickup_entered_pipe", self, "_on_pickup_entered")

func play_particles():
	particles.restart()
	if $PipeSprite.has_method("squash_and_stretch"):
		$PipeSprite.squash_and_stretch(0.25, 0.25)

func _on_player_entered(body):
	if not body is Player:
		return
	pass

func _on_pickup_entered(_type):
	play_particles()
