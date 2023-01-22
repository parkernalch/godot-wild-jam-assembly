extends StaticBody2D
class_name Platform

export(float, -1.0, 1.0) var temperature = 0.0
export(Color) var red_color
export(Color) var blue_color
export(Color) var base_color
var corner_radius = 20

var target_temp = 0
var time_factor = 1

var stylebox: StyleBoxFlat

func draw_tool():
	pass

func _ready():
	set_process(false)
	stylebox = StyleBoxFlat.new()
	stylebox.bg_color = base_color
	stylebox.corner_radius_bottom_left = corner_radius
	stylebox.corner_radius_bottom_right = corner_radius
	stylebox.corner_radius_top_left = corner_radius
	stylebox.corner_radius_top_right = corner_radius
	stylebox.border_color = Color.black
	stylebox.border_width_bottom = 1
	stylebox.border_width_top = 1
	stylebox.border_width_right = 1
	stylebox.border_width_left = 1
	$Panel.set("custom_styles/panel", stylebox)
	$Panel.visible = true
	update_shader_for_temperature()
	
func set_collider_dimensions(rect_size, offset):
	if get_node("CollisionShape2D"):
		$CollisionShape2D.queue_free()
	var collider: CollisionShape2D = CollisionShape2D.new()
	add_child(collider)
	var panel: Panel = $Panel
	var panel_center = global_position + offset
	panel.margin_left = int(rect_size.x * -0.5)
	panel.margin_right = int(rect_size.x * 0.5)
	panel.margin_top = int(rect_size.y * -0.5)
	panel.margin_bottom = int(rect_size.y * 0.5)
	
	collider.global_position = global_position + offset
	collider.shape = RectangleShape2D.new()
	collider.shape.set_extents(rect_size * 0.5)
	
	$TempSprite.position = Vector2(0, -$TempSprite.texture.height / 2 - rect_size.y / 2)
	var texture_width = $TempSprite.texture.width
	# TODO: need to adjust size of tempsprite based on rect_size.x
	pass
	
func update_shader_for_temperature():
	var temp_color = base_color
	var red_amt = lerp(Color.white, red_color, temperature)
	var blue_amt = lerp(Color.white, blue_color, 0 - temperature)
	
	temp_color = lerp(blue_amt, red_amt, (temperature + 1)/2) * base_color;
	stylebox.bg_color = temp_color
#	$Panel.set("custom_styles/panel", stylebox)
#	$.add_color_override("bg_color", Color.pink)
	update()
	$TempSprite.material.set_shader_param("temperature_value", temperature);

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
