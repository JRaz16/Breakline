class_name Player
extends CharacterBody3D
## Control script for a player-controlled character

signal health_changed(health:float)
signal inventory_changed(inventory:WeaponInventory)
signal item_collected(item_name:String)
signal lives_changed(lives:int)
signal score_changed(score:int)

@export_group("Movement")
## Determines how fast the player moves (in m/s).
@export_range(1, 10) var movement_speed:float = 5
## Determines how height the player can jump.
@export_range(1, 10) var jump_force:float = 5
## Adjsut the force of gravity affecting the player.
@export_range(1, 20) var gravity:float = 10

@export_group("Look")
## Limit how far the camera can look downward.
@export var min_look_angle:float = -90
## Limit how far the camera can look upward.
@export var max_look_angle:float = 90
## Determines how quickly the camera moves with the mouse.
@export var sensitivity:float = 10

@export_group("Combat")
## Player's health can go no higher than this.
@export var max_health: int = 100
## You must assign a value WaterBalloon scene for this property.
@export var balloon: PackedScene
## Sound effect for throwing a water balloon.
@export var sound_balloon_launch: AudioStream
## Sound effect for shooting the squirt gun,
@export var sound_gun: AudioStream

var can_shoot:bool = true
var input:Vector2 = Vector2.ZERO
var mouse_delta: Vector2 = Vector2.ZERO

var initial_position:Vector3
var inventory:WeaponInventory = WeaponInventory.new()
var reload_timer:Timer

var score: int    = 0:
	set(value):
		score = max(value, 0)
		score_changed.emit(score)	
var health: int   = 100:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health)
var nb_lives: int = 3:
	set(value):
		nb_lives = max(value, 0)
		lives_changed.emit(nb_lives)

@onready var camera: Camera3D = $Eyes
@onready var line_of_sight: RayCast3D = $Eyes/LineOfSight
@onready var sound_fx: AudioStreamPlayer = $SoundFX


func detect_collisions():
	for index in get_slide_collision_count():
		var collider: Node = get_slide_collision(index).get_collider()
		if collider.is_in_group("collect"):
			score += 1
			item_collected.emit("object")
			collider.queue_free()
			if score >= 4:
				get_tree().change_scene_to_file("res://scenes/ui/win.tscn")
		elif collider.is_in_group("ammo_gun"):
			inventory.weapons[Weapon.TYPE_GUN].increase_ammo(10)
			inventory_changed.emit(inventory)
			collider.queue_free()
		elif collider.is_in_group("ammo_auto_gun"):
			inventory.weapons[Weapon.TYPE_AUTO_GUN].increase_ammo(10)
			inventory_changed.emit(inventory)
			collider.queue_free()
		elif collider.is_in_group("ammo_grenade"):
			inventory.weapons[Weapon.TYPE_GRENADE].increase_ammo(10)
			inventory_changed.emit(inventory)
			collider.queue_free()
		elif collider.is_in_group("health_pack"):
			health = 100
			print("Ammo Collected; health is ", health)
			collider.queue_free()

func got_hit():
	health -= 10
	if health <= 0:
		restart_level()


func restart_level():
	nb_lives -= 1
	if nb_lives > 0:
		health = 100
		global_transform.origin = initial_position
	else:
		get_tree().change_scene_to_file("res://scenes/ui/lost.tscn")

func shoot():
	can_shoot = false
	inventory.decrease_curr_ammo()
	inventory_changed.emit(inventory)
	reload_timer.wait_time = inventory.get_curr_reload_time()
	reload_timer.start()
	match inventory.weapon_index:
		Weapon.TYPE_GUN, Weapon.TYPE_AUTO_GUN:
			sound_fx.stream = sound_gun
			if line_of_sight.is_colliding():
				var obj: Node = line_of_sight.get_collider()
				if obj.is_in_group("target"):
					obj.got_hit_by(self)
		Weapon.TYPE_GRENADE:
			sound_fx.stream = sound_balloon_launch
			var new_balloon:WaterBalloon = balloon.instantiate()
			get_parent().add_child(new_balloon)
			new_balloon.global_transform.origin = global_transform.origin + transform.basis * Vector3(0, 1, -1)
			new_balloon.linear_velocity = transform.basis * 6 * (Vector3.FORWARD + Vector3.UP)
			new_balloon.angular_velocity = 10 * Vector3(randf_range(-1, 1), randf_range(-2, 2), randf_range(-1, 1))
	sound_fx.play()


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	reload_timer = Timer.new()
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	add_child(reload_timer)
	initial_position = global_transform.origin
	inventory_changed.emit(inventory)
	lives_changed.emit(nb_lives)
	health_changed.emit(health)
	score_changed.emit(score)

# Called every physics tick. 'delta' is the elapsed time since the previous tick.
func _physics_process(delta):
	velocity.x = 0
	velocity.z = 0
	
	var forward: Vector3 = global_transform.basis.z
	var right: Vector3   = global_transform.basis.x
	
	var relativeDirection: Vector3 = forward * input.y + right * input.x
	velocity.x = relativeDirection.x * movement_speed
	velocity.z = relativeDirection.z * movement_speed
	
	velocity.y -= gravity * delta
	set_velocity(velocity)
	set_up_direction(Vector3.UP)
	move_and_slide()
	detect_collisions()

func _process(delta):
	camera.rotation_degrees.x -= mouse_delta.y * sensitivity * delta
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, min_look_angle, max_look_angle)
	rotation_degrees.y -= mouse_delta.x * sensitivity * delta
	mouse_delta = Vector2.ZERO

func _input(event):
	if event is InputEventMouseMotion:
		mouse_delta = event.relative
	if event.is_action("move") and not event.is_echo():
		input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").normalized()
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_force
	if event.is_action_released("change_weapon"):
		inventory.change_weapon()
		inventory_changed.emit(inventory)
		reload_timer.wait_time = inventory.get_curr_reload_time()
	if event.is_action_pressed("fire", true) and can_shoot and inventory.has_ammo_for_current():
		shoot()

func _on_reload_timer_timeout():
	can_shoot = true
	reload_timer.stop()
