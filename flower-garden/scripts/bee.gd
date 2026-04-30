class_name Bee
extends Sprite2D
## Simple computer-controlled agent that navigates a grid-based world using the A* Search algorithm.

## Required for the agent to know about the world.
@export var world:World
## Every bee should have a home.
@export var home:Hive
## How much nectar this bee can carry
@export var capacity:int = 5
## How fast the bee will move toward its destination (steps per second).
@export var speed:float = 2:
	set(new_speed):
		speed = new_speed
		step_delay = 1 / speed
## Current state of the Bee
@export var current_state:BeeState = BeeState.Idling.new(self):
	set(new_state):
		if not new_state: return # remain in the same state
		current_state._exit()
		current_state = new_state
		new_state._enter()

## How much nectar this bee is currently carrying.
var nectar:int = 0
## How many seconds between movement steps (smaller is faster)
var step_delay:float = 1 / speed
## Ensures the desired [member step_delay] between moves.
var step_timer:Timer
## Sequence of intermediate positions between the current position and the goal position.
var current_path:Array


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AStar.graph = self.world
	$AStar.search_complete.connect(_on_search_complete)
	step_timer = Timer.new()
	step_timer.one_shot = true
	step_timer.timeout.connect(self.step)
	add_child(step_timer)


# Called when there is an input event.
func _input(event:InputEvent) -> void:
	if not event.is_action_type(): return
	_on_event(BeeState.Event.new(BeeState.Event.Type.INPUT, event))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	pass # Not currently used but left here for later


func _on_event(event:BeeState.Event) -> void:
	current_state = current_state._handle_event(event)


func _on_search_complete(path:Array) -> void:
	if path.is_empty():
		_on_event(BeeState.Event.new(BeeState.Event.Type.FAILURE, null))
	else:
		_on_event(BeeState.Event.new(BeeState.Event.Type.ROUTE, path))


func _on_sniffer_area_entered(area: Area2D) -> void:
	if area.is_in_group("flowers") and not area.is_depleted():
		_on_event(BeeState.Event.new(BeeState.Event.Type.DETECTION, area))


## Attempt to find a viable path to the desired location.
func set_destination(goal:Vector2) -> void:
	var start_coords:Vector2i = position / world.tile_size
	var goal_coords:Vector2i = goal / world.tile_size
	$AStar.search(start_coords, goal_coords)


## Moves the agent to the next position on its current path, then restarts the timer for the next step.
func step() -> void:
	var next_coords = current_path.pop_back()
	position = next_coords * world.tile_size
	if len(current_path) > 0:
		step_timer.start(step_delay)
	else:
		_on_event(BeeState.Event.new(BeeState.Event.Type.ARRIVAL, null))


## Collect all necessary save data into a dictionary.
func save_data() -> Dictionary:
	var data:Dictionary = {
			"world": self.world.get_path(),
		"home": self.home.get_path(),
		"nectar": self.nectar,
		"capacity": self.capacity,
		"speed": self.speed,
		"position": self.position,
		"path": self.current_path,
		"state": self.current_state._name()
	}
	if current_state is BeeState.Exploring:
		data["direction"] = self.current_state.direction
	elif current_state is BeeState.Collecting:
		data["target"] = self.current_state.target.get_path()
	return data

## Restore the values of save properties from a dictionary.
func load_data(data:Dictionary) -> void:
	self.nectar = data["nectar"]
	self.capacity = data["capacity"]
	self.speed = data["speed"]
	self.position = Util.str_to_vec2(data["position"])
	self.current_path = data["path"].map(Util.str_to_vec2)
	self.home = get_tree().root.get_node(data["home"])
	self.world = get_tree().root.get_node(data["world"])
	$AStar.graph = self.world # make sure that AStar has a valid graph
	self.current_state = BeeState.create(data["state"], self)
	if current_state is BeeState.Exploring:
		self.current_state.direction = Util.str_to_vec2(data["direction"])
	elif current_state is BeeState.Collecting:
		self.current_state.target = get_tree().root.get_node(data["target"])
