extends CharacterBody3D


var SPEED := 10.0
var STRAFE_SPEED := 6.0
var GROUND_ACCEL := 15.0
var GROUND_FRICTION := 30.0
var AIR_ACCEL := 7.0
var AIR_CONTROL := 0.3
const JUMP_VELOCITY := 5.0

# Dash settings
var DASH_SPEED := 22.0
var DASH_TIME := 0.15

var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var dash_direction := Vector3.ZERO

# Dash meter system
var DASH_COST := 1.0
var DASH_MAX := 1.0
var DASH_RECHARGE_RATE := 0.8   # per second

var dash_energy := 1.0

# Crouch / Slide
var CROUCH_SPEED := 3.0
var SLIDE_SPEED := 9.0
var SLIDE_FRICTION := 8.0
var SLIDE_MIN_SPEED := 8.0
var CROUCH_CAMERA_OFFSET := -0.5
var SLIDE_DURATION := 0.5

var is_crouching := false
var is_sliding := false
var slide_direction := Vector3.ZERO
var slide_timer := 0.0

# Rolling
var FALL_DISTANCE_THRESHOLD := 5.0   # min fall distance to require roll
var ROLL_SPEED := 12.0
var ROLL_FRICTION := 10.0
var ROLL_DURATION := 0.5
var roll_timer := 0.0
var is_rolling := false
var roll_direction := Vector3.ZERO
var fall_distance := 0.0

var roll_start_rotation := Vector3.ZERO
var roll_progress := 0.0

# WALL MOVEMENT
var WALL_RUN_SPEED := 11.0
var WALL_RUN_GRAVITY := 0.4
var WALL_RUN_TIME := 1.5

var WALL_CLIMB_SPEED := 6.0
var WALL_JUMP_FORCE := 8.0

var is_wall_running := false
var wall_run_timer := 0.0
var wall_normal := Vector3.ZERO

var WALL_CLIMB_TIME := 0.35   # max climb duration
var wall_climb_timer := 0.0
var is_wall_climbing := false

# Mantle / Vault
var is_mantling := false
var mantle_target := Vector3.ZERO
var mantle_speed := 8.0

# Camera tilt
var target_camera_tilt := 0.0

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var dash_meter = $"../UI/Control/DashMeter"
@onready var standing_collision = $StandingCollisionShape3D
@onready var crouching_collision = $CrouchingCollisionShape3D
@onready var wall_ray_left := $Neck/WallRayLeft
@onready var wall_ray_right := $Neck/WallRayRight
@onready var wall_ray_forward := $Neck/WallRayForward
@onready var ledge_ray := $Neck/LedgeRay

func _ready():
	crouching_collision.disabled = true


func _process(delta):
	dash_meter.value = dash_energy
	dash_meter.visible = dash_energy < DASH_MAX

func _unhandled_input(event: InputEvent) -> void: 
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			neck.rotate_y(-event.relative.x * Settings.mouse_sensitivity/10)
			camera.rotate_x(-event.relative.y * Settings.mouse_sensitivity/10)
			if not is_rolling:
				camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))


func _physics_process(delta: float) -> void:
	# Update dash timers
	if dash_timer > 0:
		dash_timer -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		fall_distance -= velocity.y * delta
	else:
		# Landed
		if fall_distance >= FALL_DISTANCE_THRESHOLD:
			if Input.is_action_pressed("crouch"):
				is_rolling = true
				roll_timer = ROLL_DURATION
				roll_direction = Vector3(velocity.x, 0, velocity.z).normalized()
				
				roll_start_rotation = camera.rotation
				roll_progress = 0.0
				
			else:
				velocity.x = 0
				velocity.z = 0
		fall_distance = 0
		
	# WALL RUN DETECTION
	if not is_on_floor() and not is_wall_running:
		
		if not is_wall_running and wall_ray_forward.is_colliding() and Input.is_action_pressed("move_forward"):
			var normal = wall_ray_forward.get_collision_normal()
			# Only allow vertical surfaces
			if abs(normal.y) < 0.2:
				is_wall_climbing = true
				wall_climb_timer = WALL_CLIMB_TIME
					
				velocity.x = move_toward(velocity.x, 0, 20 * delta)
				velocity.z = move_toward(velocity.z, 0, 20 * delta)
				
				velocity.y = WALL_CLIMB_SPEED

		if is_wall_climbing:
			wall_climb_timer -= delta
			if wall_climb_timer <= 0 or not Input.is_action_pressed("move_forward") or not wall_ray_forward.is_colliding():
				is_wall_climbing = false
				
		if wall_ray_left.is_colliding() and Input.is_action_pressed("move_forward") and velocity.y < 1:
			var normal = wall_ray_left.get_collision_normal()
			if abs(normal.y) < 0.2:
				is_wall_running = true
				wall_run_timer = WALL_RUN_TIME
				wall_normal = normal
				velocity.y = 0
				target_camera_tilt = deg_to_rad(-12)
			
		elif wall_ray_right.is_colliding() and Input.is_action_pressed("move_forward") and velocity.y < 1:
			var normal = wall_ray_right.get_collision_normal()
			if abs(normal.y) < 0.2:
				is_wall_running = true
				wall_run_timer = WALL_RUN_TIME
				wall_normal = normal
				velocity.y = 0
				target_camera_tilt = deg_to_rad(12)
			
	if is_wall_running:
		wall_run_timer -= delta
		# reduced gravity
		velocity.y += get_gravity().y * WALL_RUN_GRAVITY * delta
		# move along wall
		var forward_dir = -neck.global_transform.basis.z
		var wall_direction = forward_dir.slide(wall_normal).normalized()
		
		var target_velocity = wall_direction * WALL_RUN_SPEED
		velocity.x = lerp(velocity.x, target_velocity.x, 8 * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, 8 * delta)
		
		if wall_run_timer <= 0 or is_on_floor() \
		or (!wall_ray_left.is_colliding() and !wall_ray_right.is_colliding()):
			is_wall_running = false
			target_camera_tilt = 0

	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		
		elif is_wall_running:
			velocity = wall_normal * WALL_JUMP_FORCE
			velocity.y = JUMP_VELOCITY
			is_wall_running = false
			target_camera_tilt = deg_to_rad(0)

	# Input
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Get neck basis
	var basis = neck.global_transform.basis
	var forward = basis.z
	var right = basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()
	
	var direction = (right * input_dir.x + forward * input_dir.y).normalized()

	# Current horizontal velocity
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	
	# DASH MOVEMENT
	if dash_timer > 0:
		velocity.x = dash_direction.x * DASH_SPEED
		velocity.z = dash_direction.z * DASH_SPEED
		move_and_slide()
		return

	if is_on_floor():
		dash_energy += DASH_RECHARGE_RATE * delta
		dash_energy = min(dash_energy, DASH_MAX)
		
		var current_forward_speed = horizontal_velocity.dot(forward)
		var current_strafe_speed = horizontal_velocity.dot(right)

		var target_forward_speed = input_dir.y * (CROUCH_SPEED if is_crouching else SPEED)
		var target_strafe_speed = input_dir.x * STRAFE_SPEED

		# Strafe logic
		if input_dir.y > 0 and input_dir.x != 0:
			# Slight acceleration when moving backward diagonally
			current_strafe_speed = move_toward(
				current_strafe_speed,
				target_strafe_speed,
				GROUND_ACCEL * 0.5 * delta   # smaller accel for subtle feel
			)
		else:
			# Instant strafe normally
			current_strafe_speed = target_strafe_speed

		# Forward / Backward logic
		if input_dir.y < 0:
			current_forward_speed = move_toward(
				current_forward_speed,
				target_forward_speed,
				GROUND_ACCEL * delta
			)

		elif input_dir.y > 0:
			current_forward_speed = input_dir.y * STRAFE_SPEED

		else:
			# Friction
			current_forward_speed = move_toward(
				current_forward_speed,
				0,
				GROUND_FRICTION * delta
			)

		var new_velocity = forward * current_forward_speed + right * current_strafe_speed
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z

	elif not is_wall_running:
		horizontal_velocity = horizontal_velocity.move_toward(
			direction * SPEED,
			AIR_ACCEL * delta
		)
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
		
		
	# Dash input
	if Input.is_action_just_pressed("dash") and dash_energy >= DASH_COST:
		if direction != Vector3.ZERO:
			dash_direction = direction
		else:
			dash_direction = -forward # dash forward if no input
	
		dash_timer = DASH_TIME
		dash_energy -= DASH_COST
	
	# CROUCH INPUT
	if Input.is_action_pressed("crouch") and not is_rolling:
		if not is_crouching:
			is_crouching = true
			standing_collision.disabled = true
			crouching_collision.disabled = false

			# Check if we should slide
			var speed = Vector3(velocity.x,0,velocity.z).length()
			if speed > SLIDE_MIN_SPEED and is_on_floor():
				is_sliding = true
				slide_direction = Vector3(velocity.x,0,velocity.z).normalized()
				slide_timer = SLIDE_DURATION  # start slide timer

	else:
		if is_crouching:
			is_crouching = false
			is_sliding = false
			standing_collision.disabled = false
			crouching_collision.disabled = true
			
			
	# Slide / Roll Movement
	if is_sliding or is_rolling:
		
		if is_rolling:
			var current_speed = Vector3(velocity.x, 0, velocity.z).length()
			var move_velocity = roll_direction * current_speed
			
			velocity.x = move_velocity.x
			velocity.z = move_velocity.z
			
			roll_timer -= delta
			if roll_timer <= 0:
				is_rolling = false
				
		else:
			var move_velocity = slide_direction * SLIDE_SPEED
			move_velocity = move_velocity.move_toward(Vector3.ZERO, SLIDE_FRICTION * delta)
			
			velocity.x = move_velocity.x
			velocity.z = move_velocity.z
			
			slide_timer -= delta
			if slide_timer <= 0 or move_velocity.length() < 1:
				is_sliding = false
			
	# Camera crouch lowering
	var target_height = CROUCH_CAMERA_OFFSET if is_crouching or is_sliding or is_rolling else 0.0
	camera.position.y = lerp(camera.position.y, target_height, 10 * delta)
		
	if is_rolling:
		roll_progress += delta / ROLL_DURATION
		var roll_angle = deg_to_rad(360) * (1 - roll_progress)
		camera.rotation.x = roll_angle
		
		if roll_progress >= 1.0:
			is_rolling = false
			roll_progress = 0.0
			camera.rotation.x = 45
			
	else:
		camera.rotation.z = lerp(camera.rotation.z, target_camera_tilt, 8 * delta)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))
		
	# LEDGE VAULT
	if ledge_ray.is_colliding() and not is_on_floor() and not is_wall_running and not wall_ray_forward.is_colliding() and Input.is_action_pressed("move_forward"):
		
		var ledge_point = ledge_ray.get_collision_point()
		
		if not is_mantling and velocity.y <= 0:
			is_mantling = true
			mantle_target = ledge_point + Vector3.UP * 1.2
			velocity = Vector3.ZERO

	if is_mantling:
		global_position = global_position.move_toward(mantle_target, mantle_speed * delta)
		
		if global_position.distance_to(mantle_target) < 0.1:
			is_mantling = false
	
	# FOV effect based on speed
	var forward_speed = velocity.dot(-forward)
	forward_speed = max(forward_speed, 0) # ignore backward

	var speed_ratio = clamp(forward_speed / SPEED, 0.0, 1.0)
	var target_fov = lerp(75.0, 80.0, speed_ratio)
	
	# Smooth FOV change
	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)

	move_and_slide()
	


func _on_goal_ring_body_entered(body: Node3D) -> void:
	if body == self:
		call_deferred("go_to_end_scene")
		
func _on_death_plane_body_entered(body: Node3D) -> void:
	if body == self:
		call_deferred("go_to_end_scene")
		
func go_to_end_scene():
	get_tree().change_scene_to_file("res://Scenes/end_screne.tscn")
