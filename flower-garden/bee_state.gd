class_name BeeState
extends Object

class Event:
	enum Type { ARRIVAL, DETECTION, ROUTE, FAILURE, INPUT}
	
	var type:Type
	var payload:Variant
	
	func _init(type:Type, data:Variant):
		self.type = type
		self.playload = data

var bee:Bee = null

func _init(bee:Bee):
	self.bee = bee
	
func _enter() -> void:
	pass

func _exit() -> void:
	pass
	
func _handle_event(event:Event) -> BeeState:
	if event.type == Event.Type.INPUT:
		return _handle_input(event.payload as InputEvent)
	return self

func _handle_input(event:InputEvent) -> BeeState:
	if not event.is_echo():
		if event.is_action_pressed(&"idle"):
			return null
		elif event.is_action_pressed(&"explore"):
			return null
		elif event.is_action_pressed(&"collect"):
			return null
		elif event.is_action_pressed(&"return"):
			return null
	return self
	
func _update(delta:float) -> void: pass

class Idling extends BeeState:
	func _enter() -> void:
		print("Entered Idling state")
	func _handle_event(event:Event) -> BeeState:
		return super._handle_event(event)
		
class Exploring extends BeeState:
	var direction:Vector2 = 2 * Vector2.RIGHT
	
