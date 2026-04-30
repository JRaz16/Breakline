class_name ChasingState
extends NPCState
## Governs the behavior of a character who is chasing after a target.


## Find a path to the target.
func calc_path():
	npc.nav_agent.set_target_position(npc.target.global_transform.origin)


func enter():
	print("ENTER STATE: Chasing")
	npc.nav_agent.navigation_finished.connect(_on_navigation_finished)
	calc_path()
	super.enter()


func exit():
	print("EXIT STATE: Chasing")
	super.exit()
	npc.nav_agent.navigation_finished.disconnect(_on_navigation_finished)
	npc.nav_agent.set_target_position(npc.global_position)
	npc.stop()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "Running"
	animator.get_animation(animation).loop_mode = Animation.LOOP_LINEAR


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	npc.orient()

	if not npc.target: return
	if npc.look_for_player():
		var distance_to_player: float = (npc.target.global_transform.origin - npc.global_transform.origin).length()
		if distance_to_player < 1.5:
			npc.change_state(get_node(^"../Punching"))
		else:
			npc.change_state(get_node(^"../Shooting"))


# Called every tick of the physics subsystem. 'delta' is the elapsed time since the previous tick.
func _physics_process(_delta) -> void:
	if NavigationServer3D.map_get_iteration_id(npc.nav_agent.get_navigation_map()) == 0:
		return
	var next_path_position: Vector3 = npc.nav_agent.get_next_path_position()
	var new_velocity: Vector3       = npc.global_position.direction_to(next_path_position) * npc.run_speed
	if npc.nav_agent.avoidance_enabled:
		npc.nav_agent.set_velocity(new_velocity)
	else:
		npc._on_velocity_computed(new_velocity)


## Signal callback to find a new path after reaching the end of the previous one.
func _on_navigation_finished():
	calc_path()
