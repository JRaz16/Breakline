class_name Player2D
extends CharacterBody2D
## Simple player behavior for a side-scrolling platformer

## Sent whenever the player collects coins
signal collected(coins:int)

##Player walk speed in pixels/sec.
@export_range(0, 1000, 10) var SPEED: float = 300.0
##Vertical Jump speed in pixels/sec.
@export_range(-1000, 0, 10) var JUMP_VELOCITY: float = -400.0

var coins_collected:int = 0
var direction: float = 0
var is_falling:bool = false

func jump(height: int = JUMP_VELOCITY):
	print("Jump Pressed")
	velocity.y = height
	$Avatar.play("jump")
		
func move():
	direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
		$Avatar.play("walk")
		$Avatar.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		$Avatar.play("idle")

func ground_check(delta:float):
	# Add the gravity
	if is_on_floor():
		if is_falling:
			print("landed")
			$Avatar.play("landed")
		is_falling = false
	else:
		velocity += get_gravity() * delta
		is_falling = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if is_on_floor():
			$Avatar.play("crouch")
			## jump()
	if event.is_action("move_horizontal"):
		move()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	ground_check(delta)
	

	# Handle jump.
	## if Input.is_action_just_pressed("ui_accept") and is_on_floor():
	## 	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	#direction = Input.get_axis("ui_left", "ui_right")

	move_and_slide()


func _on_avatar_animation_finished() -> void:
	if $Avatar.animation == "crouch":
		jump() 
		
	if $Avatar.animation == "landed":
		$Avatar.play("idle")
		



func _on_spring_body_entered(body: Node2D) -> void:
		if body == self:
			print("Goal Reached")
			jump(-2000)
	
