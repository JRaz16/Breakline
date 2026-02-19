extends Zone
## Represents a user-controlled dot


# Called when the node enters the scene tree for the first time.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#center += event.relative
		center = get_global_mouse_position()
		$"./Shapey".position = center
		boundary_test()
		queue_redraw()

func _process(delta: float) -> void:
	pass #This overides Zone.process to do something


func boundary_test() -> void:
	var d = PointTest.on_line_fuzzy(center, $"../Boundary".start, $"../Boundary".n, radius)
	if d > 0:
		color.r = 0
		color.g = 1
		$"Shapey".play("green")
	elif d < 0:
		color.r = 1
		color.g = 1
		$"Shapey".play("yellow")
	else:
		color.r = 1
		color.g = 0
		$"Shapey".play("purple")
