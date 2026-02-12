extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body is Player2D:
		body.coins_collected += 1
		body.collected.emit(body.coins_collected)
		print("Coins collected: " + str(body.coins_collected))
		self.queue_free()
