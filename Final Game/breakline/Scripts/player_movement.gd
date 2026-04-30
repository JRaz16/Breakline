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
var DASH_TIME := 0.13

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
var SLIDE_SPEED := 10.0
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
var WALL_RUN_TIME := 0.7

var WALL_CLIMB_SPEED := 6.0
var WALL_JUMP_FORCE := 6.0

var is_wall_running := false
var wall_run_timer := 0.7
var wall_normal := Vector3.ZERO
var climb_wall_normal := Vector3.ZERO

var wall_run_direction := Vector3.ZERO
var wall_run_start_wall = null

var WALL_CLIMB_TIME := 0.4  # max climb duration
var wall_climb_timer := 0.0
var is_wall_climbing := false
var last_wall: StaticBody3D = null
var last_wall_run_wall = null
var wall_climb_locked := false
var just_wall_climbed := false

var WALL_JUMP_GRACE_TIME := 0.5
var wall_jump_grace_timer := 0.0
var last_climb_normal := Vector3.ZERO

var climb_locked_direction := Vector3.ZERO
var climb_start_position := Vector3.ZERO

# Mantle / Vault
var is_mantling := false
var mantle_target := Vector3.ZERO
var mantle_start := Vector3.ZERO
var mantle_timer := 0.0
var MANTLE_DURATION := 0.22

# Camera
var is_quick_turning := false
var quick_turn_target := 0.0
var QUICK_TURN_SPEED := 15.0
var target_camera_tilt := 0.0
var pitch := 0.0
var PITCH_LIMIT_UP := deg_to_rad(-80)
var PITCH_LIMIT_DOWN := deg_to_rad(75)

@onready var neck := $Neck
@onready var camera := $Neck/Camera3D
@onready var dash_meter = $"../UI/Control/DashMeter"
@onready var standing_collision = $StandingCollisionShape3D
@onready var crouching_collision = $CrouchingCollisionShape3D
@onready var wall_ray_left := $Neck/WallRayLeft
@onready var wall_ray_right := $Neck/WallRayRight
@onready var wall_ray_forward :RayCast3D= $Neck/WallRayForward
@onready var ledge_ray := $Neck/LedgeRay
@onready var mantle_ray := $Neck/MantleRay

func _ready():
	crouching_collision.disabled = true


func _process(delta):
	dash_meter.value = dash_energy
	dash_meter.visible = dash_energy < DASH_MAX

func _unhandled_input(event: InputEvent) -> void: 
	if Input.is_action_just_pressed("quick_turn") and not is_quick_turning:
		is_quick_turning = true
		quick_turn_target = neck.rotation.y + PI
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			if not is_quick_turning:
				neck.rotate_y(-event.relative.x * Settings.mouse_sensitivity/20)
			pitch -= event.relative.y * Settings.mouse_sensitivity / 20
			pitch = clamp(pitch, PITCH_LIMIT_UP, PITCH_LIMIT_DOWN)

			camera.rotation.x = pitch


func _physics_process(delta: float) -> void:
	# Quick turn
	if is_quick_turning:
		neck.rotation.y = lerp_angle(neck.rotation.y, quick_turn_target, QUICK_TURN_SPEED * delta)
		if abs(angle_difference(neck.rotation.y, quick_turn_target)) < 0.01:
			neck.rotation.y = quick_turn_target
			is_quick_turning = false
	# Update timers
	if dash_timer > 0:
		dash_timer -= delta
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	if wall_jump_grace_timer > 0:
		wall_jump_grace_timer -= delta
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
		
		is_wall_climbing = false
		
		if is_on_floor():
			last_wall = null
			just_wall_climbed = false
			is_wall_running = false
			target_camera_tilt = 0.0
			wall_run_start_wall = null
			last_wall_run_wall = null
		
		fall_distance = 0
		
	# WALL CLIMB DETECTION
	if not is_on_floor():
		var current_wall = null
		if wall_ray_forward.is_colliding():
			current_wall = wall_ray_forward.get_collider()
		# START wall climb ONLY once
		if not is_wall_climbing:
			if current_wall != null and Input.is_action_pressed("move_forward") and current_wall != last_wall:
				var normal = wall_ray_forward.get_collision_normal()

				# only vertical walls
				if abs(normal.y) < 0.2:
					if current_wall != last_wall:
						is_wall_climbing = true
						wall_climb_timer = WALL_CLIMB_TIME
						climb_wall_normal = normal
						last_wall = current_wall

						print("Started wall climb: ", current_wall.name)

		# ACTIVE wall climb (LOCKED state)
		if is_wall_climbing:
			wall_climb_timer -= delta

			# constantly stick player to wall
			if climb_wall_normal != Vector3.ZERO:
				var stick_force = -climb_wall_normal * 2.5
				velocity.x = stick_force.x
				velocity.z = stick_force.z

			# move upward
			velocity.y = WALL_CLIMB_SPEED
			print("wall climbing")

			# only end when timer runs out
			if wall_climb_timer <= 0:
				is_wall_climbing = false
				just_wall_climbed = true
				
				# grace period
				wall_jump_grace_timer = WALL_JUMP_GRACE_TIME
				last_climb_normal = climb_wall_normal
				
		if not is_wall_climbing and wall_jump_grace_timer <= 0:
			climb_wall_normal = Vector3.ZERO
				
		# WALL RUN TIMER
		if not is_wall_climbing and not is_wall_running and velocity.y < 1:

			current_wall = null
			var normal = Vector3.ZERO

			if wall_ray_left.is_colliding():
				current_wall = wall_ray_left.get_collider()
				normal = wall_ray_left.get_collision_normal()
				#target_camera_tilt = deg_to_rad(-12)

			elif wall_ray_right.is_colliding():
				current_wall = wall_ray_right.get_collider()
				normal = wall_ray_right.get_collision_normal()
				#target_camera_tilt = deg_to_rad(12)

			# valid wall check
			if current_wall != null and current_wall != last_wall and current_wall != last_wall_run_wall and abs(normal.y) < 0.2 and Input.is_action_pressed("move_forward"):

				is_wall_running = true
				wall_run_timer = WALL_RUN_TIME
				wall_normal = normal
				wall_run_start_wall = current_wall
				last_wall_run_wall = current_wall
				target_camera_tilt = deg_to_rad(-12) if wall_ray_left.is_colliding() else deg_to_rad(12)

				var forward_dir = -neck.global_transform.basis.z
				forward_dir.y = 0
				forward_dir = forward_dir.normalized()

				wall_run_direction = forward_dir.slide(normal).normalized()

				velocity.y = 3.5
	
	if is_wall_running:
		dash_energy += DASH_RECHARGE_RATE * delta
		dash_energy = min(dash_energy, DASH_MAX)
		wall_run_timer -= delta
		
		if wall_run_timer < 0.2:
			velocity.y -= 2.0 * delta

		# softer gravity (feels like weight, not float)
		velocity.y += get_gravity().y * 0.65 * delta

		# fixed direction movement (no jitter)
		var target_velocity = wall_run_direction * WALL_RUN_SPEED

		velocity.x = move_toward(velocity.x, target_velocity.x, 25 * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, 25 * delta)

		# EXIT CONDITIONS
		var wall_lost = (!wall_ray_left.is_colliding() and !wall_ray_right.is_colliding())
		var time_up = wall_run_timer <= 0
		var hit_ground = is_on_floor()

		if wall_lost or time_up or hit_ground:
			is_wall_running = false
			target_camera_tilt = 0.0

			# lock wall like climb system
			if wall_run_start_wall != null:
				last_wall = wall_run_start_wall

	# Jump
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
			print("jumping")
			
		elif is_wall_climbing or wall_jump_grace_timer > 0:
			var normal = climb_wall_normal if is_wall_climbing else last_climb_normal
			var away = normal.normalized()
			
			velocity.x = away.x * WALL_JUMP_FORCE
			velocity.z = away.z * WALL_JUMP_FORCE
			velocity.y = 4.5
			print("jumping away")
			
			climb_locked_direction = Vector3(velocity.x, 0, velocity.z).normalized()
			
			is_wall_climbing = false
			wall_jump_grace_timer = 0.0
			
			stop_wall_states()
			just_wall_climbed = true

		elif is_wall_running:
			var forward_dir = -neck.global_transform.basis.z
			forward_dir.y = 0
			forward_dir = forward_dir.normalized()

			# push away from wall + stronger forward boost
			var away = wall_normal.normalized()

			var jump_dir = (forward_dir + away * 0.6).normalized()

			velocity = jump_dir * WALL_JUMP_FORCE
			velocity.y = JUMP_VELOCITY

			is_wall_running = false
			target_camera_tilt = 0.0
			

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
		
	elif not is_wall_running and not is_wall_climbing:
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
		
	
	# FOV effect based on speed
	var forward_speed = velocity.dot(-forward)
	forward_speed = max(forward_speed, 0) # ignore backward

	var speed_ratio = clamp(forward_speed / SPEED, 0.0, 1.0)
	var target_fov = lerp(75.0, 80.0, speed_ratio)
	
	# Smooth FOV change
	camera.fov = lerp(camera.fov, target_fov, 8.0 * delta)

	move_and_slide()
	
func stop_wall_states():
	is_wall_climbing = false
	is_wall_running = false
	climb_wall_normal = Vector3.ZERO
	wall_normal = Vector3.ZERO

func _on_goal_ring_body_entered(body: Node3D) -> void:
	if body == self:
		go_to_next_level()
		
func _on_death_plane_body_entered(body: Node3D) -> void:
	if body == self:
		call_deferred("go_to_end_scene")
		
func go_to_end_scene():
	get_tree().change_scene_to_file("res://Scenes/end_screne.tscn")
	
func get_next_level_path() -> String:
	var current_path = get_tree().current_scene.scene_file_path
	
	var base_name = current_path.get_file().get_basename()
	
	var parts = base_name.split("_")
	
	if parts.size() < 2:
		push_error("Invalid level name format: " + base_name)
		return ""
	
	# Next level
	var level_number = int(parts[1])
	var next_level_number = level_number + 1
	
	return "res://Scenes/levels/level_%d.tscn" % next_level_number
	
func go_to_next_level():
	var next_path = get_next_level_path()
	if ResourceLoader.exists(next_path):
		get_tree().change_scene_to_file(next_path)
	else:
		print("No more levels → going to end scene")
		go_to_end_scene()
