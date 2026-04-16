class_name AStar
extends Node
## Implementation of the classic A* search algorithm for path-finding.

signal search_complete(path: Array)

@export var graph:Node = null

var came_from:Dictionary
var cost_so_far:Dictionary
var frontier:PriorityQueue = PriorityQueue.new()
var path_to_goal:Array = []

var goal:Vector2i
var thread:Thread
var mutex:Mutex
var semaphore:Semaphore

func _ready():
	if not graph:
		graph = $/root/Game/World
	semaphore = Semaphore.new()
	mutex = Mutex.new()
	thread = Thread.new()
	thread.start(search_loop)
	
func search_loop():
	while true:
		semaphore.wait()
		mutex.lock()
		while not frontier.is_empty():
			var current = frontier.extract()
			if current == goal:
				break
			for next in graph.neighbors(current):
				var new_cost = cost_so_far[current] + graph.cost(current, next)
				if is_inf(new_cost):
					continue
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
