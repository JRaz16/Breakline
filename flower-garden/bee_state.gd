class_name BeeState extends Node
## Simple implementation of the object-oriented state pattern.

## Factory pattern
static func create(state_name:StringName, a_bee:Bee):
	match state_name:
		&"Exploring": return Exploring.new(a_bee)
		&"Collecting": return Collecting.new(a_bee, null)
		&"Returning": return Returning.new(a_bee)
		_: return Idling.new(a_bee)


var bee:Bee = null

func _init(a_bee:Bee): self.bee = a_bee

func _name() -> StringName: return &"BeeState"

#region Base State Pattern

func _enter() -> void:
	print("Enter '%s' state" % _name())

func _exit() -> void:
	print("Exit '%s' state" % _name())

func _handle_event(event:Event) -> BeeState:
	if event.type == Event.Type.INPUT:
		return _handle_input(event.payload as InputEvent)
	return null

func _handle_input(event:InputEvent) -> BeeState:
	if not event.is_echo():
		if event.is_action_pressed(&"idle"):
			return Idling.new(bee)
		elif event.is_action_pressed(&"explore"):
			return Exploring.new(bee)
		elif event.is_action_pressed(&"collect"):
			return Collecting.new(bee, null)
		elif event.is_action_pressed(&"return"):
			return Returning.new(bee)
	return null # this means stay in the same state


func _update(_delta:float) -> void: pass

#endregion

#region Derived States

## Represents the behavior of a bee that is not doing anything
class Idling extends BeeState:
	func _name() -> StringName: return &"Idling"

## Represents the behavior of a bee that is searching for nectar
class Exploring extends BeeState:
	var direction:Vector2 = 2 * Vector2.RIGHT
	func _name() -> StringName: return &"Exploring"
	func explore() -> void:
		direction = direction.rotated(randf_range(-PI / 2, PI / 2))
		bee.set_destination(bee.position + direction * bee.world.tile_size)
	func _enter() -> void:
		super._enter()
		bee.get_node(^"Sniffer").set_deferred(&"monitoring", true)
		explore()
	func _exit() -> void:
		bee.get_node(^"Sniffer").set_deferred(&"monitoring", false)
		super._exit()
	func _handle_event(event:Event) -> BeeState:
		if event.type == Event.Type.DETECTION:
			return Collecting.new(bee, event.payload)
		elif event.type == Event.Type.ROUTE:
			bee.current_path = event.payload
			bee.step()
		elif event.type == Event.Type.ARRIVAL or event.type == Event.Type.FAILURE:
			explore()
		return super._handle_event(event)

class Collecting extends BeeState:
	var target:Node2D
	func _name() -> StringName: return &"Collecting"
	func _init(a_bee:Bee, node:Node2D):
		super(a_bee)
		self.target = node
	func _enter() -> void:
		super._enter()
		bee.set_destination(target.global_position)
	func _handle_event(event:Event) -> BeeState:
		if event.type == Event.Type.ROUTE:
			bee.current_path = event.payload
			bee.step()
		elif event.type == Event.Type.ARRIVAL:
			bee.nectar += target.collect()
			if bee.nectar == bee.capacity:
				return Returning.new(bee)
			else:
				return Exploring.new(bee)
		elif event.type == Event.Type.FAILURE:
			return Exploring.new(bee)
		return super._handle_event(event)

class Returning extends BeeState:
	func _name() -> StringName: return &"Returning"
	func _enter() -> void:
		super._enter()
		bee.set_destination(bee.home.global_position)
	func _handle_event(event:Event) -> BeeState:
		if event.type == Event.Type.ROUTE:
			bee.current_path = event.payload
			bee.step()
		elif event.type == Event.Type.ARRIVAL:
			bee.home.nectar += bee.nectar
			bee.nectar = 0
			return Exploring.new(bee)
		elif event.type == Event.Type.FAILURE:
			return Idling.new(bee)
		return super._handle_event(event)

#endregion

#region Inner Auxiliary Classes

## Wrapper class for event data
class Event:
	## Bees distinguish several kinds of event
	enum Type { ARRIVAL, DETECTION, ROUTE, FAILURE, INPUT }
	## Indicates the kind of event
	var type:Type
	## The data caried by this event
	var payload:Variant
	## Construct a new event
	func _init(t:Type, data:Variant):
		self.type = t
		self.payload = data

#endregion
