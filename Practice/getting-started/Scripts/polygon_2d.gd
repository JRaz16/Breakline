extends CharacterBody2D

@export var move_incriment: int = 10

func _input(event: InputEvent) -> void:
	if (event.is_action_pressed("move_up")):
		position.y -= move_incriment
	if (event.is_action_pressed("move_left")):
		position.x -= move_incriment
	if (event.is_action_pressed("move_down")):
		position.y += move_incriment
	if (event.is_action_pressed("move_right")):
		position.x += move_incriment
	
func _process(delta: float) -> void:
	pass
	
