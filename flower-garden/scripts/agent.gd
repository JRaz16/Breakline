class_name Bee
extends Sprite2D
## Simple computer-controlled agent that navigates a grid-based world using the A* Search algorithm.

enum State {
	IDLING,
	EXPLORING,
	COLLECTING,
	RETURNING
}

## Required for the agent to know about the world
@export var world:World
## Required for the agent to have a goal to go to
@export var goal:Node
## How many seconds between movement steps (smaller is faster)
@export var step_delay:float = 2

@export var current_state: State = State.IDLING:
	set(new_state):
		current_state = new_state
		print("Current state = ", current_state)

## Ensures the desired [member step_delay] between moves.
var step_timer:Timer
## Sequence of intermediate positions between the current position and the goal position.
var current_path:Array

func set_destination(goal:Vector2) -> void:
	var start_coords:Vector2i = position / world.tile_size
	var goal_coords:Vector2i = goal / world.tile_size
	$AStar.search(start_coords, goal_coords)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AStar.search_complete.connect(_on_search_complete)
	step_timer = Timer.new()
	step_timer.one_shot = true
	step_timer.timeout.connect(self.step)
	add_child(step_timer)

func _on_search_complete(path:Array) -> void:
	if not path.is_empty():
		current_path = path
		step()

# Called when there is an input event.
func _input(event:InputEvent) -> void:
	if not event.is_echo():
		match current_state:
			State.IDLING:
				if event.is_action_pressed(&"explore"):
					current_state = State.EXPLORING
					var direction:Vector2 = 2 * Vector2.RIGHT
					direction = direction.rotated(randf_range(-PI / 2, PI/2))
					set_destination(position + direction * world.tile_size)
			State.EXPLORING:
				if event.is_action_pressed(&"collect"):
					current_state = State.COLLECTING
				elif event.is_action_pressed(&"idle"):
					current_state = State.IDLING
			State.COLLECTING:
				if event.is_action_pressed(&"return"):
					current_state = State.RETURNING
				elif event.is_action_pressed(&"idle"):
					current_state = State.IDLING
			State.RETURNING:
				if event.is_action_pressed(&"idle"):
					current_state = State.IDLING
	#if event.is_action_released("ui_accept"):
		#var start_coords:Vector2i = position / world.tile_size
		#var goal_coords:Vector2i = goal.position / world.tile_size
		#print(start_coords, goal_coords)
		#current_path = AStar.search(world, start_coords, goal_coords)
		#if not current_path.is_empty():
			#step_timer.start(step_delay)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta:float) -> void:
	pass # Not currently used but left here for later


## Moves the agent to the next position on its current path, then restarts the timer for the next step.
func step() -> void:
	var next_coords = current_path.pop_back()
	position = next_coords * world.tile_size
	if len(current_path) > 0:
		step_timer.start(step_delay)
