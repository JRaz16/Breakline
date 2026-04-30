extends Node3D
## Manager script for periodically spawning new enemy NPCs.


## Assign an NPC scene for this property.
@export var npc: PackedScene
## Route waypoints are the positions of its Node3D children. 
@export var patrol_route:Node

var spawning_timer:Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	spawning_timer = Timer.new()
	add_child(spawning_timer)
	spawning_timer.wait_time = 10
	spawning_timer.timeout.connect(instantiate_npc)
	spawning_timer.start()


func instantiate_npc():
	var new_scene: Node = load("res://scenes/agents/npc.tscn").instantiate()
	new_scene.get_node(^"States/Patrolling").route = self.patrol_route
	get_parent().add_child(new_scene)
	new_scene.global_position = self.global_position
