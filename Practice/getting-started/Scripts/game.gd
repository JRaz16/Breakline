extends Node

@export var gameover_scene:PackedScene = preload("res://Scenes/gameover.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_inventory"):
		get_viewport().set_input_as_handled()
		$InventoryLayer/InventoryUi.open()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_poi_body_entered(body: Node2D) -> void:
	if body is Player2D:
		##get_tree().change_scene_to_packed(gameover_scene)
		
		get_tree().call_deferred(&"change_scene_to_packed", gameover_scene)
	
