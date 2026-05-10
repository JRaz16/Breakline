extends Area3D

@export var spin_speed := 5.0
@export var bob_height := 0.1
@export var bob_speed := 5.0

var time := 0.0
var start_y := 0.0

func _ready():
	start_y = position.y

func _process(delta: float) -> void:
	time += delta

	rotate_y(spin_speed * delta)
	position.y = start_y + sin(time * bob_speed) * bob_height
