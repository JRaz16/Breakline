class_name Hero
extends Character
## Player-controlled character


## Determines the movement velocity from the current user inputs
func get_input():
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = input_dir * stats.speed


## Ensures that the character always faces the mouse position.
func orient():
	var mouse_position = get_viewport().get_mouse_position()
	var direction = (self.position - mouse_position).normalized()
	var new_angle =  PI + atan2(direction.y, direction.x) 
	self.rotation = new_angle


func _ready():
	super._ready()


func _input(event):
	if event.is_action_pressed(&"cycle_attack"):
		current_attack = current_attack + 1
	if event.is_action_pressed(&"attack"):
		attack()
	#if event.is_action_pressed(&"shoot"):
		#shoot()
		
func _process(delta):
	orient()
	super._process(delta)


func _physics_process(delta):
	get_input()
	super._physics_process(delta)
