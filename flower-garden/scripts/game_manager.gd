class_name GameManager extends Node
## Simple global script for basic game management


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_released(&"pause"):
		pause_game()
	elif event.is_action_released(&"load"):
		load_game()
	elif event.is_action_released(&"save"):
		save_game()


func pause_game() -> void:
	get_tree().paused = not get_tree().paused

func load_game() -> void:
	var was_paused = get_tree().paused
	get_tree().paused = true
	if not FileAccess.file_exists("user://flowergarden.save"):
		print("Error: save game file not found!")
		get_tree().paused = false
		return # nothing to do because no save file
	var save_nodes = get_tree().get_nodes_in_group(&"persist")
	for node in save_nodes:
		node.queue_free()
		await node.tree_exited
	var save_file = FileAccess.open("user://flowergarden.save", FileAccess.READ)
	while save_file.get_position() < save_file.get_length():
		var json_string = save_file.get_line()
		var node_data = JSON.parse_string(json_string)
		if not node_data:
			print("JSON Parse Error!")
			continue
		var new_object = load(node_data["filename"]).instantiate()
		get_node(node_data["parent"]).add_child(new_object)
		new_object.load_data(node_data)	
	get_tree().paused = was_paused

func save_game() -> void:
	var was_paused = get_tree().paused
	get_tree().paused = true
	var save_file = FileAccess.open("user://flowergarden.save", FileAccess.WRITE)
	var save_nodes:Array[Node] = get_tree().get_nodes_in_group(&"persist")
	for node in save_nodes:
		if node.scene_file_path.is_empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue
		if not node.has_method(&"save_data"):
			print("persistent node '%s' is missing a save_data( method) function, skipped" % node.name)
			continue
		var node_data = node.save_data()
		node_data["filename"] = node.get_scene_file_path()
		node_data["parent"] = node.get_parent().get_path()
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)
	get_tree().paused = was_paused
