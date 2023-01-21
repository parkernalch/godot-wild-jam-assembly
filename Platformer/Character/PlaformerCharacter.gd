extends KinematicBody2D
class_name Player

signal movement_started(movement_direction)
signal changing_direction(current_velocity, input_direction)
signal jumped(is_grounded)
signal landed(impact_velocity)
signal trail_start(start_pos)
signal trail_end()

onready var cast: RayCast2D = $DownCast
onready var cast2: RayCast2D = $DownCast2
onready var left_cast: RayCast2D = $LeftCast
onready var right_cast: RayCast2D = $RightCast
onready var coyote_timer: Timer = $CoyoteTimer
onready var jump_buffer_timer: Timer = $JumpBufferTimer

export var size_per_unit = 32

export var platformer_data : Resource
var data : PlatformerData

# Forces
var grounded_forces
var airborne_forces
var base_gravity = 9.8
# Movement
var cached_velocity = Vector2.ZERO
var velocity = Vector2.ZERO
var top_speed
var temp_speed_modifier = 1
var horizontal_input = 0
var time_since_last_move = 0

# Jump
var is_grounded
var is_jumping = false
var jump_force = 0
var jump_pressed = false
var jump_released = false
var jumps_remaining = 0

# wall
var on_wall = null # "left" or "right"
var wall_drag_strength = 0

# Health
var health = 100
var max_health = 100
var health_material
var heat_amount = .2

class Accel:
	var acceleration: float
	var deceleration: float
	func _init(a, d):
		self.acceleration = a
		self.deceleration = d

func _ready():
	assert(platformer_data is PlatformerData)
	data = platformer_data
	health_material = $AnimatedSprite.get_material();
	health_material.set_shader_param("health",health/max_health);
	EventBus.connect("platformer_resource_updated", self, "_on_resource_updated")
	coyote_timer.connect("timeout", self, "_on_coyote_time_expired")

	if data.wall_drag_decay_time > 0:
		$WallDragDecayTimer.wait_time = data.wall_drag_decay_time
		$WallDragDecayTimer.one_shot = true
	$WallJumpControlTimer.wait_time = data.wall_jump_control_timeout
	$WallJumpControlTimer.one_shot = true
	set_resource_derived_properties()

func _on_coyote_time_expired():
	if jumps_remaining > 0:
		jumps_remaining -= 1

func _on_resource_updated(resource):
	print("got resource updated: " + str(resource))
	data = resource
	set_resource_derived_properties()
	
func set_resource_derived_properties():
	# scale top speed to unit size (resolution)
	top_speed = data.move_top_speed * size_per_unit
	# calculate jump force (v_0) to match max jump height
	var height = data.jump_max_height * size_per_unit
	var g_up = data.gravity_up_modifier * base_gravity * size_per_unit
	jump_force = sqrt(2 * g_up * height)
	grounded_forces = precalculateAcceleration(
		data.move_acceleration_time,
		data.move_deceleration_time
	)
	airborne_forces = grounded_forces
	if data.jump_has_air_control:
		airborne_forces = precalculateAcceleration(0.4, 0.4)
	coyote_timer.wait_time = data.jump_coyote_timeout
	coyote_timer.one_shot = true
	jump_buffer_timer.wait_time = data.jump_buffer_timeout
	jump_buffer_timer.one_shot = true
	pass

func precalculateAcceleration(accel_time, decel_time):
	# calculate acceleration required to reach full speed in t_to_speed
	var acceleration = 2 * ( top_speed * temp_speed_modifier) / pow(accel_time , 2)
	# calculate deceleration required to reach full stop in t_to_stop
	var deceleration = 2 * (top_speed * temp_speed_modifier) * decel_time / pow(decel_time, 2)
	return Accel.new(acceleration, deceleration)

func _process(delta):
	horizontal_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")		
	jump_pressed = Input.is_action_just_pressed("jump")
	if jump_pressed:
		jump_buffer_timer.start(data.jump_buffer_timeout)
	jump_released = Input.is_action_just_released("jump")
	
func apply_horizontal_forces(delta, forces):
	var isNearTopSpeed = abs(velocity.x) >= top_speed * 0.95 * temp_speed_modifier
	if abs(horizontal_input) == 0:
		# prevents float at slow speeds
		if abs(velocity.x) < top_speed * 0.1:
			return 0
		# apply deceleration
		return velocity.x + sign(velocity.x) * -1 * forces.deceleration * delta
	else:
		var v = velocity.x
		var has_wall_jumped = $WallJumpControlTimer.time_left > 0
		if has_wall_jumped:
			var wall_jump_control_factor = 1 if not has_wall_jumped else 1 - $WallJumpControlTimer.time_left / $WallJumpControlTimer.wait_time
			v += forces.acceleration * delta * horizontal_input * wall_jump_control_factor
			return v
		v += forces.acceleration * delta * horizontal_input
		if isNearTopSpeed:
			# allows for quick turnraound at top speeds
			return top_speed * sign(horizontal_input) * temp_speed_modifier
		# apply acceleration
		return v
	return velocity.x

func apply_vertical_forces(delta):
	var v = velocity.y
	# handle jumps

	# handle variable gravity
	if velocity.y > 0:
		v += base_gravity * data.gravity_down_modifier * delta * size_per_unit
	else:
		v += base_gravity * data.gravity_up_modifier * delta * size_per_unit
	
	# handle wall drag
	if on_wall != null and velocity.y > 0:
		var wall_drag = v * (wall_drag_strength) * sign(v) * -1
		v += wall_drag
	return v
	
func _physics_process(delta):
	var was_airborne = not is_grounded
	var was_stationary = time_since_last_move > 0.5 and is_grounded
	is_grounded = cast.is_colliding() or cast2.is_colliding()
	var left_wall = left_cast.get_collider()
	var right_wall = right_cast.get_collider()
	if is_grounded || left_wall is Platform || right_wall is Platform:
		apply_heat_differential(delta)
	
	var is_on_left_wall = left_cast.is_colliding() and horizontal_input < 0
	var is_on_right_wall = right_cast.is_colliding() and horizontal_input > 0
	
	health_material.set_shader_param("health",health/max_health);

	if is_on_left_wall:
		on_wall = "left"
	elif is_on_right_wall:
		on_wall = "right"
	else:
		on_wall = null
	 
	if on_wall != null:
		wall_drag_strength = max(wall_drag_strength - delta / data.wall_drag_decay_time, 0)
	
	if was_airborne and is_grounded:
		$WallJumpControlTimer.stop()
		emit_signal("landed", cached_velocity)
	if not was_airborne and not is_grounded:
		coyote_timer.start(data.jump_coyote_timeout)
	
	if is_grounded:
		is_jumping = false
		jumps_remaining = data.jump_midair_count + 1
		wall_drag_strength = data.wall_drag
		velocity.x = apply_horizontal_forces(delta, grounded_forces)
	else:
		velocity.x = apply_horizontal_forces(delta, airborne_forces)
		pass

	if (jump_pressed or jump_buffer_timer.time_left > 0):
		if on_wall != null and not is_grounded:
			velocity.y = - data.wall_jump_force * sin(data.wall_jump_angle)
			velocity.x = - data.wall_jump_force * cos(data.wall_jump_angle)
			if on_wall == "left":
				velocity.x *= -1
			$WallJumpControlTimer.start()
		elif jumps_remaining > 0:
			velocity.y = -jump_force
		emit_signal("jumped", is_grounded)
		jump_pressed = false
		jumps_remaining -= 1
		jump_buffer_timer.stop()
	if data.jump_is_variable && jump_released && velocity.y < 0:
		velocity.y *= 0.2
		jump_released = false
	
	velocity.y = apply_vertical_forces(delta)
	

	if is_grounded && abs(velocity.x) > 0:
		emit_signal("trail_start", $trail_pos.global_position)
#		health -= heat_amount;
#		if (int(health) * 10) % 100 == 0:
#			recalculateAccelerationFromHealth(health)
		if health <= 0:
			print("dead X_X")
			set_physics_process(false)
			set_process(false)
	else:
		emit_signal("trail_end")

	velocity = move_and_slide_with_snap(
		velocity, 
		Vector2.UP, 
		Vector2.UP, 
		true
	)
	cached_velocity = velocity
	
	if was_stationary and velocity.x != 0:
		emit_signal("movement_started", velocity)
	if is_grounded and velocity.x * horizontal_input < 0:
		emit_signal("changing_direction", velocity, horizontal_input)
	
	if velocity == Vector2.ZERO:
		time_since_last_move += delta
	else:
		time_since_last_move = 0

func recalculateAccelerationFromHealth(health_val):
	grounded_forces = precalculateAcceleration(
		data.move_acceleration_time + lerp(1, 0, health_val / 2),
		data.move_deceleration_time + lerp(1, 0, health_val / 2)
	)

func apply_heat_differential(delta):
	var effective_temp = 0;
	if is_on_wall():
		var left_wall = left_cast.get_collider()
		var right_wall = right_cast.get_collider()
		if left_wall is Platform:
			effective_temp += left_wall.temperature
		if right_wall is Platform:
			effective_temp += right_wall.temperature
		pass
	if is_on_floor():
		var floor1 = cast.get_collider()
		var floor2 = cast.get_collider()
		if floor1 == floor2 and floor1 is Platform:
			effective_temp += floor1.temperature
		else:
			if floor1 is Platform:
				effective_temp += floor1.temperature
			if floor2 is Platform:
				effective_temp += floor2.temperature
		pass
	health = clamp(health - effective_temp, 0, 100)
	health_material.set_shader_param("health",health/max_health);
	if temp_speed_modifier != effective_temp + 1:
		temp_speed_modifier = max(effective_temp + 1, 0.15)
#		recalculateAccelerationFromHealth(temp_speed_modifier)
	if health < 0:
		set_process(false)
		set_physics_process(false)
		print("dead X_X")
