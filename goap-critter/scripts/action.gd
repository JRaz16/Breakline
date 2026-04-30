class_name Action
extends Object

## A unique identifier for this action
var name:String
## A numeric cost associated with this action
var cost:float
## A set of properties required in order to perform this action
var precondition:WorldState
## A set or properties that result from performing this action
var postcondition:WorldState
## 
var procedure:Callable

func _init(name:String, cost:float, before:WorldState, after:WorldState, proc:Callable = func():return):
	self.name = name
	self.cost = cost
	self.precondition = before
	self.postcondition = after
	self.procedure = proc


func _to_string():
	return self.name + "[" + str(self.cost) + "](" + str(self.precondition) + "->" + str(self.postcondition) + ")"

## Gets the cost of this action
func get_cost() -> float:
	return cost

## Gets the value of a given property that is required to perform this action
func requires(prop:Property.Key) -> Property.Value:
	return precondition.get_property(prop)

## Gets the value of a given property that results from performing this action
func produces(prop:Property.Key) -> Property.Value:
	return postcondition.get_property(prop)

## Determines whether this action can be performed in the given world state
func doable(given:WorldState) -> bool:
	return given.satisfies(precondition)

func execute():
	procedure.call()
