extends Control

var elapsed_time: float = 0.0
onready var label = $NinePatchRect/Label

func _ready():
	EventBus.connect("level_started", self, "_on_level_started")
	EventBus.connect("level_completed", self, "_on_level_completed")
	EventBus.connect("pause", self, "_on_pause")
	EventBus.connect("resume", self, "_on_resume")
	EventBus.connect("ready_to_proceed", self, "_on_level_completed")
	set_process(false)
	_on_level_started()
	
func _on_pause():
	set_process(false)
	
func _on_resume():
	set_process(true)	

func _on_level_started():
	set_process(true)
	pass

func _on_level_completed():
	print(elapsed_time)
	Globals.set_current_stage_time(elapsed_time)
	
func set_label():
	var hr = int(elapsed_time / 3600)
	var hr_s = elapsed_time - hr * 3600
	var mi = int(hr_s / 60)
	var mi_s = hr_s - mi * 60
	var s = int(mi_s)
	var s_s = mi_s - s
	var ms = int(s_s * 1000)
	var minutes =  (str(mi) + ":").pad_zeros(3)
	var seconds = (str(s) + ":").pad_zeros(3)
	var milis = str(ms).pad_zeros(3)
	label.text = seconds + milis
	
func _process(delta):
	elapsed_time += delta
	set_label()
	pass
