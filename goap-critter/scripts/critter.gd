class_name Critter
extends Sprite2D

#region Signal declarations
## Emit upon successfully completing an action
signal action_performed(name:String)
## Emit when unable to complete an action
signal action_canceled(name:String)
#endregion

#region Inspector properties
## Required for the agent to know about the world
@export var world:World

@export_subgroup("State Variables")
## Indicates whether or not the critter is in bed
@export var in_bed:bool = false
## How many berries does the critter have
@export_range(0, 5) var berriesHeld:int = 0:
	set(value): berriesHeld = clamp(value, 0, 5)
## How cold is the critter
@export_range(0, 1) var chill:float = 0:
	set(value): chill = clamp(value, 0, 1)
## How hungry is the critter
@export_range(0, 1) var hunger:float = 0:
	set(value): hunger = clamp(value, 0, 1)
## How lonely  is the critter
@export_range(0, 1) var loneliness:float = 0:
	set(value): loneliness = clamp(value, 0, 1)
## How tired is the critter
@export_range(0, 1) var sleepiness:float = 0:
	set(value): sleepiness = clamp(value, 0, 1)

@export_subgroup("State Change")
## How quickly the critter gets hungry
@export_range(0, 2) var hunger_rate:float = 0.025
## How quickly the critter gets cold when away from fire
@export_range(0, 2) var cooling_rate:float = 0.1
## How quickly the critter warms up when near a fire
@export_range(0, 2) var warming_rate:float = 1
## How quickly the critter gets lonely when away from friends
@export_range(0, 2) var lonely_rate:float = 0.005
## How quickly the critter gets tired when not in bed
@export_range(0, 2) var sleepy_rate:float = 0.01
	

@export_subgroup("Action Parameters")
## Duration of a cuddle session in seconds
@export_range(0.1, 5, 0.1) var cuddle_time:float = 1
## Time needed to consume a berry in seconds
@export_range(0.1, 5, 0.1) var eating_time:float = 0.5
## Time needed to gather a berry in seconds
@export_range(0.1, 5, 0.1) var gather_time:float = 1
## Duration of a restful sleep in seconds
@export_range(0.1, 5, 0.1) var sleep_time:float = 2
## Indicates how fast the agent will move toward the goal (smaller is faster)
@export_range(0, 5, 0.1) var step_delay_secs:float = 0.2

@export_subgroup("Noises")
## Audio clips to go with the actions of this critter
@export var noises:Dictionary = {
	"chomp": preload("res://audio/sounds/398730__anthousai__dog-eat-treat-grab.wav"),
	"snore": preload("res://audio/sounds/560058__isaroru__pug-roncando.wav"),
	"purr": preload("res://audio/sounds/262309__steffcaffrey__cat-purrtwit4.wav"),
	"rustle": preload("res://audio/sounds/396014__morganpurkis__rustling-grass-1.wav"),
	"fire": preload("res://audio/sounds/188038__antumdeluge__fire-crackling.wav")
}
#endregion

var action_timer:Timer
var actions:Array[Action] = []
var current_path:Array
var current_plan:Array[Action]
var neighborhood:Array[Node2D] = []
var goals:Array[WorldState] = [
	WorldState.new({
		"is_cold": Property.Value.new(self, false)
	}),
	WorldState.new({
		"is_hungry": Property.Value.new(self, false)
	}),
	WorldState.new({
		"is_sleepy": Property.Value.new(self, false)
	}),
	WorldState.new({
		"is_lonely": Property.Value.new(self, false)
	})
]

#region Node Overrides
# Constructor
func _init():
	init_actions()


# Called when the node enters the scene tree for the first time.
func _ready():
	action_timer = Timer.new()
	action_timer.one_shot = true
	add_child(action_timer)


# Called on input events
func _input(event):
	pass


# Called every frame. 'delta' is the elapsed time in seconds since the previous frame.
func _process(delta):
	if action_timer.is_stopped():
		if current_plan.is_empty():
			make_plan()
		else:
			execute_plan()

	hunger += hunger_rate * delta

	if get_state().get_property("near_fire").value:
		chill -= warming_rate * delta
	else:
		chill += cooling_rate * delta

	if not get_state().get_property("near_friend").value:
		loneliness += lonely_rate * delta
	if not get_state().get_property("near_bed").value:
		sleepiness += sleepy_rate * delta
#endregion


#region Planning
## Begin performing the sequence of actions in the current plan
func execute_plan():
	if current_plan.is_empty(): return

	var next_action:Action = current_plan.front()
	if next_action:
		next_action.execute()


## Run the GOAP algorithm to devise a plan to satisfy the highest-priority goal
func make_plan():
	var current_state = get_state()
	for goal in goals:
		if current_state.satisfies(goal):
			print("satisfied!")
			continue
		var plan:Array[Action] = Goap.search(actions, current_state, goal)
		var plan_str:String = "Plan for " + str(goal.properties.keys()) + " is... "
		for action in plan:
			plan_str += action.name + " > "
		print(plan_str.substr(0, plan_str.length() - 3))
		current_plan = plan
		break
#endregion


#region Action Callbacks
## Reduce the critter's loneliness when near a friend
func cuddle() -> bool:
	if not get_state().get_property("near_friend").value: return false
	make_noise("purr", cuddle_time)
	action_timer.start(cuddle_time)
	await action_timer.timeout
	loneliness -= 0.5
	action_performed.emit("cuddle")
	return true


## Reduce the critter's hunger at the cost of a berry if it has one
func eat() -> bool:
	if berriesHeld == 0: return false
	make_noise("chomp", eating_time)
	action_timer.start(eating_time)
	berriesHeld -= 1
	await action_timer.timeout
	hunger -= 0.5
	action_performed.emit("eat")
	return true


## Gain a berry if the critter is near a bush
func gather() -> bool:
	if not get_state().get_property("near_bush").value: return false
	make_noise("rustle", gather_time)
	action_timer.start(gather_time)
	await action_timer.timeout
	berriesHeld += 1
	action_performed.emit("gather")
	return true


## Get out of bed so that the critter can move around again
func get_up() -> bool:
	if not in_bed: return false
	action_timer.start(0.5)
	await action_timer.timeout
	in_bed = false
	action_performed.emit("get up")
	return true


## Plot a route to some desired location and begin traveling there
func goto(place:String) -> bool:
	var destination:Node2D = get_tree().get_first_node_in_group(place)
	if not destination:
		action_canceled.emit("goto")
		return false
	print("Going to '" + place + "'" + str(destination.position))
	var start_coords:Vector2i = position / world.tile_size
	var goal_coords:Vector2i = destination.position / world.tile_size
	#print(start_coords, goal_coords)
	current_path = AStar.search(world, start_coords, goal_coords)
	action_timer.timeout.connect(self.move_step)
	action_timer.start(step_delay_secs)
	return true


## Critter cannot move around if it is in bed
func lie_down() -> bool:
	if not get_state().get_property("near_bed").value: return false
	action_timer.start(0.5)
	await action_timer.timeout
	in_bed = true
	action_performed.emit("lie down")
	return true


## Reduce the critter's sleepiness if it is in bed
func sleep() -> bool:
	if not in_bed: return false
	make_noise("snore", sleep_time)
	action_timer.start(sleep_time)
	await action_timer.timeout
	sleepiness -= 0.5
	action_performed.emit("sleep")
	return true


## Reduce the critter's chill when near a heat source
func warm_up() -> bool:
	if not get_state().get_property("near_fire").value: return false
	make_noise("fire", chill / warming_rate)
	action_timer.start(1 / warming_rate)
	await action_timer.timeout
	action_performed.emit("warm up")
	return true
#endregion


#region Auxiliary functions
## Retrieves the critter's current state formatted for us with GOAP
func get_state() -> WorldState:
	var in_group:Callable = func(tag): return func(node):return node.is_in_group(tag)
	return WorldState.new({
		"is_cold": Property.Value.new(self, chill >= 0.5),
		"is_hungry": Property.Value.new(self, hunger >= 0.5),
		"is_lonely": Property.Value.new(self, loneliness >= 0.5),
		"is_sleepy": Property.Value.new(self, sleepiness >= 0.5),
		"near_fire": Property.Value.new(self, neighborhood.any(in_group.call("fire"))),
		"near_bush": Property.Value.new(self, neighborhood.any(in_group.call("bush"))),
		"near_bed": Property.Value.new(self, neighborhood.any(in_group.call("bed"))),
		"near_friend": Property.Value.new(self, neighborhood.any(in_group.call("friend"))),
		"in_bed": Property.Value.new(self, in_bed),
		"has_berries": Property.Value.new(self, berriesHeld > 0)
	})


## Plays a sound effect for us during an action
func make_noise(title, duration):
	var noise:AudioStream = noises[title]
	$Noises.stream = noise
	$Noises.pitch_scale = noise.get_length() / duration
	$Noises.play()


## Moves one step further along the current navigation path
func move_step():
	if current_path.is_empty():
		action_timer.timeout.disconnect(self.move_step)
		action_performed.emit("goto")
		return
	var next_coords = current_path.pop_back()
	position = next_coords * world.tile_size
	action_timer.start(step_delay_secs)
#endregion


#region Signal Callbacks
func _on_neighborhood_area_entered(area):
	neighborhood.append(area)


func _on_neighborhood_area_exited(area):
	neighborhood.erase(area)


func _on_action_performed(name):
	current_plan.pop_front()
	print("performed " + name + " action")


func _on_action_canceled(name):
	current_plan.clear()
#endregion

#region GOAP Setup
## Set up the actions for this critter
func init_actions():
	actions = [
		Action.new(
			"goto bed", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, false)
			}),
			WorldState.new({
				"near_bed": Property.Value.new(self, true),
				"near_bush": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, false),
				"near_friend": Property.Value.new(self, false)
			}),
			func(): goto("bed")
		),
		Action.new(
			"goto bush", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, false)
			}),
			WorldState.new({
				"near_bed": Property.Value.new(self, false),
				"near_bush": Property.Value.new(self, true),
				"near_friend": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, false)
			}),
			func(): goto("bush")
		),
		Action.new(
			"goto fire", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, false)
			}),
			WorldState.new({
				"near_bed": Property.Value.new(self, false),
				"near_bush": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, true),
				"near_friend": Property.Value.new(self, false)
			}),
			func(): goto("fire")
		),
		Action.new(
			"goto friend", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, false)
			}),
			WorldState.new({
				"near_bed": Property.Value.new(self, false),
				"near_bush": Property.Value.new(self, false),
				"near_fire": Property.Value.new(self, false),
				"near_friend": Property.Value.new(self, true)
			}),
			func(): goto("friend")
		),
		Action.new(
			"lie down", 1,
			WorldState.new({
				"near_bed": Property.Value.new(self, true),
				"in_bed": Property.Value.new(self, false)
			}),
			WorldState.new({
				"in_bed": Property.Value.new(self, true)
			}),
			lie_down
		),
		Action.new(
			"warm up", 1,
			WorldState.new({
				"near_fire": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_cold": Property.Value.new(self, false)
			}),
			warm_up
		),
		Action.new(
			"gather berries", 1,
			WorldState.new({
				"near_bush": Property.Value.new(self, true),
			}),
			WorldState.new({
				"has_berries": Property.Value.new(self, true)
			}),
			gather
		),
		Action.new(
			"eat berries", 1,
			WorldState.new({
				"has_berries": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_hungry": Property.Value.new(self, false)
			}),
			eat
		),
		Action.new(
			"sleep", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_sleepy": Property.Value.new(self, false)
			}),
			sleep
		),
		Action.new(
			"get up", 1,
			WorldState.new({
				"in_bed": Property.Value.new(self, true),
			}),
			WorldState.new({
				"in_bed": Property.Value.new(self, false)
			}),
			get_up
		),
		Action.new(
			"cuddle", 1,
			WorldState.new({
				"near_friend": Property.Value.new(self, true),
			}),
			WorldState.new({
				"is_lonely": Property.Value.new(self, false)
			}),
			cuddle
		)
	]
#endregion
