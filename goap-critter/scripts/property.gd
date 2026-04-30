class_name Property
extends Object

## Unique identifier for a property of a character or the game world.
class Key:
	var name:String

	func _init(name:String):
		self.name = name

## Data indicating the state of one property of a character or the game world.
class Value:
	## A game object that this describes eeeor applies to
	var subject:Node
	## The data value for this property
	var value:Variant

	func _init(obj:Node, v:Variant):
		subject = obj
		value = v

	func _to_string():
		return "(" + str(subject) + "," + str(value) + ")"

	func equals(other:Value):
		return other.subject == self.subject and other.value == self.value
