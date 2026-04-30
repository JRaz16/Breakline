class_name AStar
extends Node
## Implementation of the classic A* search algorithm for path-finding.

## Notifies observers that the search has ended; includes a path if one was found.
signal search_complete(path:Array)

## Reference to a discrete neighbor graph representing locations in the world
@export var graph:Node = null

var came_from:Dictionary
var cost_so_far:Dictionary
var frontier:PriorityQueue = PriorityQueue.new()
var path_to_goal:Array = []

var goal:Vector2i

var canceled:bool = false
var thread:Thread = null
var mutex:Mutex
var semaphore:Semaphore

func _exit_tree() -> void:
	canceled = true
	semaphore.post()
	thread.wait_to_finish()


func _ready():
	mutex = Mutex.new()
	semaphore = Semaphore.new()
	thread = Thread.new()
	thread.start(search_loop)


func search_loop():
	while not canceled:
		semaphore.wait()
		mutex.lock()
		while not frontier.is_empty():
			var current = frontier.extract()
			if current == goal: break
			for next in graph.neighbors(current):
				var new_cost = cost_so_far[current] + graph.cost(current, next)
				if next not in cost_so_far or new_cost < cost_so_far[next]:
					came_from[next] = current
					cost_so_far[next] = new_cost
					var priority = new_cost + heuristic(next, goal)
					frontier.insert(next, priority)
		var p = goal
		while p in came_from:
			path_to_goal.append(p)
			p = came_from[p]
		search_complete.emit.call_deferred(path_to_goal)
		mutex.unlock()

## Performs a heuristic search for the shortest path between the given start
## and goal locations.
func search(start:Vector2i, destination:Vector2i) -> void:
	mutex.lock()
	came_from.clear()
	came_from[start] = null
	cost_so_far.clear()
	cost_so_far[start] = 0
	frontier.clear()
	frontier.insert(start, 0)
	path_to_goal.clear()
	goal = destination
	mutex.unlock()
	semaphore.post()


## Manhattan distance on a square grid
static func heuristic(a, b) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)
