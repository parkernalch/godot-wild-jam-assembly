extends StaticBody2D
class_name Platform

export(float, -1.0, 1.0) var temperature = 0.0

var target_temp = 0
var time_factor = 1

func _ready():
	set_process(false)
#	set_temp(rand_range(-1, 1), 1)
	update_shader_for_temperature()
	pass
	
func update_shader_for_temperature():
	$NinePatchRect.material.set_shader_param("temperature_value", temperature)
	$TempSprite.material.set_shader_param("temperature_value", temperature);

	print($TempSprite.material.get_shader_param("temperature_value"))
	
func set_temp(temp, delay):
	time_factor = 1 / delay * (1 if target_temp > temperature else -1)
	target_temp = temp
	$Label.text = "Temp: " + str(target_temp)
	set_process(true)
	pass
	
func _process(delta):
	$TempSprite.material.set_shader_param("temperature_value", temperature);
	temperature += time_factor * delta
	update_shader_for_temperature()
	if time_factor > 0 and temperature >= target_temp:
		temperature = target_temp
		set_process(false)
	if time_factor < 0 and temperature <= target_temp:
		temperature = target_temp
		set_process(false)
