class_name PatrollingState
extends NPCState
## Governs the behavior of an NPC who is following a prescribed patrol route.


@export var route:Node = null

var current_wp:Node3D # NPC is on-route to this waypoint 
var wp_index:int = 0 # index of the current waypoint in the route


## Find a path to the next patrol waypoint.
func calc_patrol_path() -> void:
	#if route.is_empty(): return
	if route.get_child_count() == 0:
		npc.change_state(get_node(^"../Idling"))
		return
	current_wp = route.get_children()[wp_index]
	npc.nav_agent.set_target_position(current_wp.global_transform.origin)


func enter():
	print("ENTER STATE: Patrolling")
	npc.nav_agent.navigation_finished.connect(_on_navigation_finished)
	calc_patrol_path()
	super.enter()


func exit():
	print("EXIT STATE: Patrolling")
	super.exit()
	npc.nav_agent.navigation_finished.disconnect(_on_navigation_finished)
	npc.nav_agent.set_target_position(npc.global_position)
	npc.stop()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "Walking"
	animator.get_animation(animation).loop_mode = Animation.LOOP_LINEAR

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:
	npc.orient()

	if npc.look_for_player():
		npc.change_state(get_node(^"../Shooting"))
	if npc.velocity.is_zero_approx():
		return


# Called every physics tick. 'delta' is the elapsed time since the previous tick.
func _physics_process(_delta) -> void:
	if NavigationServer3D.map_get_iteration_id(npc.nav_agent.get_navigation_map()) == 0:
		return
	var next_path_position: Vector3 = npc.nav_agent.get_next_path_position()
	var new_velocity: Vector3 = npc.global_position.direction_to(next_path_position) * npc.walk_speed
	if npc.nav_agent.avoidance_enabled:
		npc.nav_agent.set_velocity(new_velocity)
	else:
		npc._on_velocity_computed(new_velocity)


## Signal callback to find a new path after reaching the end of the previous one.
func _on_navigation_finished():
	wp_index = (wp_index + 1) % route.get_child_count()
	calc_patrol_path()
