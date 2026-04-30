class_name WorldState
extends Object

var properties:Dictionary


func _init(props:Dictionary):
	properties = props

func _to_string():
	return str(properties)

## Used for fast lookup of world state in dictionary/hash table
func hash():
	return properties.hash()

## Makes a copy of this world state
func duplicate():
	return WorldState.new(properties.duplicate())

## Combines the given world state with this one.
## Overwrites values of existing properties with the new ones.
func merge(from:WorldState):
	properties.merge(from.properties, true)

## Returns the number of properties in this world state
func size():
	return properties.size()

## Determines whether this world state specifies the given property.
func has(prop):
	return properties.has(prop)

## Adds a property to this world state, or overwrites the value if already present.
func add_property(prop, value):
	properties[prop] = value
	return true

## Returns this world state's value for the given property if it exists.
func get_property(prop):
	return properties.get(prop)

## Removes a property from this worl state.
func drop_property(prop):
	properties.erase(prop)

## Determines whether all properties of the goal state are present in this state
## with their required values.
func satisfies(goal:WorldState) -> bool:
	for key in goal.properties:
		if not self.has(key) or not self.get_property(key).equals(goal.get_property(key)):
			return false
	return true

## If this state satisfies the precondition of the given action, then we modify
## this state to match the postcondition of that action.
func apply(action:Action) -> bool:
	if not self.satisfies(action.precondition):
		return false
	self.merge(action.postcondition)
	return true
