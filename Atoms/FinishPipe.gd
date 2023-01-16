extends StaticBody2D

onready var player_detector: Area2D = $EntryArea
onready var particles: CPUParticles2D = $CPUParticles2D

func _ready():
	player_detector.connect("body_entered", self, "_on_player_entered")

func play_particles():
	particles.restart()

func _on_player_entered(body):
	if not body is Player:
		return
	play_particles()
