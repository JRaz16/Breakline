class_name CrossHair
extends TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewport_size: Vector2 = get_viewport().size
	self.position = viewport_size / 2 - self.size / 2
