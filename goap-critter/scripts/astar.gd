class_name AStar
extends Object


static func search(graph, start, goal):
	var frontier = PriorityQueue.new()
	frontier.insert(start, 0)
	var came_from = {}
	var cost_so_far = {}
	came_from[start] = null
	cost_so_far[start] = 0

	while not frontier.is_empty():
		#print(frontier.heap[0].value, " ", frontier.heap[0].key)
		var current = frontier.extract()

		if current == goal:
			break

		for next in graph.neighbors(current):
			var new_cost = cost_so_far[current] + graph.cost(current, next)
			if next not in cost_so_far or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				var priority = new_cost + heuristic(goal, next)
				frontier.insert(next, priority)
				came_from[next] = current

	var n = goal
	var path = []
	while n != start:
		if n not in came_from:
			break
		path.append(n)
		n = came_from[n]			
	#print(path)
	return path

## Manhattan distance on a square grid
static func heuristic(a, b):
	return abs(a.x - b.x) + abs(a.y - b.y)
