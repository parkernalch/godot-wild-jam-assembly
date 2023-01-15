extends Node2D

var states_stack = []
var current_state = null

var states = null

func _ready():
	states = get_children()
	for state in states:
		print(state.name)
	# print(states)
	# print(get_children())

func _change_state(new_state):
	current_state = new_state
	print(states)