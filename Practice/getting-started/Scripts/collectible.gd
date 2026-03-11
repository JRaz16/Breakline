extends Area2D

@export var item:Item

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item: $Sprite2D.texture = item.icon


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.has_node("Inventory"):
		var inv = body.get_node("Inventory")
		if inv.add_item(item):
			queue_free()
