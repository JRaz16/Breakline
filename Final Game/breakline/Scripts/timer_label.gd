extends Label

var display_timer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	display_timer += delta

	if display_timer >= 0.03:
		display_timer = 0.0
		text = GameManager.get_time_string()
