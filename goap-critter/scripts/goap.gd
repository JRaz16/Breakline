class_name Goap
extends Object

## Attempt to perform a sequence of actions under a given world state.
## If any action action fails to be applied due to an unsatisfied
## precondition, then we cease executing the plan.
static func execute(plan:Array[Action], state:WorldState) -> bool:
	for action in plan:
		if not state.apply(action):
			return false
	return true

## Computes a "distance" measurement between two world states that indicates
## how much they differ. Specifically, we use a variant of Levenstein string
## edit distance that tallies the number of properties in the goal state that
## are missing from or different in the source state.
static func dist(src:WorldState, dst:WorldState):
	var d:float = 0
	for prop in dst.properties:
		if not src.has(prop) or not src.get_property(prop).equals(dst.get_property(prop)):
			d += 1
	return d

## Determines whether two states conflict by having different values for the
## same property. If one state lacks a property that the other one has, then
## this is not considered to be a conflict.
static func conflict(src:WorldState, dst:WorldState):
	for key in dst.properties:
		if src.has(key) and not src.get_property(key).equals(dst.get_property(key)):
			return true
	return false

## Tries to reconcile an action's pre- and post-conditions with a desired
## goal state by removing from the goal any matching properties of the action's
## postcondition and adding to the goal any unsatisfied properties of the
## action's precondition. If there is a conflict between the goal and the
## conditions of the action, then they cannot be unified and you return null.
static func unify(action:Action, goal:WorldState):
	var new_goal:WorldState = goal.duplicate()
	# drop any properties of the goal that will be satisfied by the action's postcondition
	for prop in new_goal.properties:
		# get the corresponding property of the actions postcondition...
		if action.postcondition.has(prop):
			var val = action.postcondition.get_property(prop)
			if not val.equals(new_goal.get_property(prop)):
				return null
			# if the action results in the desired state then rmove
			new_goal.drop_property(prop)
	# if action doesn't change our goal state then it's a loop, can't unify
	if new_goal.size() == goal.size(): return null
	# add properties to the goal if they are unsatisfied preconditions of the action
	for prop in action.precondition.properties:
		var val = action.precondition.get_property(prop)
		if not new_goal.has(prop):
			new_goal.add_property(prop, val)
		elif not val.equals(new_goal.get_property(prop)):
			return null
	return new_goal

## Implements A* search to find the most efficient plan for reaching the goal.
static func search(actions:Array[Action], current_state:WorldState, goal:WorldState) -> Array[Action]:
	var plan:Array[Action] = []
	var came_from:Dictionary = {}
	var cost_so_far:Dictionary = {}
	came_from[goal] = null
	cost_so_far[goal] = 0

	var frontier:PriorityQueue = PriorityQueue.new()
	frontier.insert(goal, cost_so_far[goal])

	var start:WorldState = null
	while not frontier.is_empty():
		var current_goal:WorldState = frontier.extract()

		if current_state.satisfies(current_goal):
			start = current_goal
			break

		for action in actions:
			var next:WorldState = unify(action, current_goal)
			if next == null: continue

			var new_cost = cost_so_far[current_goal] + action.get_cost()
			if next not in cost_so_far or new_cost < cost_so_far[next]:
				cost_so_far[next] = new_cost
				var priority = new_cost + dist(next, current_state)
				frontier.insert(next, priority)
				came_from[next] = { "state": current_goal, "action": action }
	# Construct a plan from the start state to the goal state, if possible
	var n:WorldState = start
	while n != goal:
		if n not in came_from: break
		plan.append(came_from[n].action)
		n = came_from[n].state
	return plan
