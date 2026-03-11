class_name Inventory extends Node

signal inventory_updated

@export var max_slots:int = 20

var slots:Array[Dictionary] = []

func add_item(new_item:Item, qty:int = 1) -> bool:
	if not new_item:
		return false
	
	var remaining:int = qty
	
	#try to stack
	if new_item.is_stackable:
		for slot in slots:
			if slot and slot.item.name == new_item.name \
			and slot.quantity < new_item.max_stack:
				var qty_to_add: int = min(remaining, new_item.max_stack - slot.quantity)
				slot.quantity += qty_to_add
				remaining -= qty_to_add
				# End early if nothing else is remaining
				if remaining <= 0: break
	var idx: int = 0
	while idx < max_slots and remaining > 0:
		if not slots[idx]:
			var qty_to_add: int = min(remaining, new_item.max_stack)
			slots[idx] = {"item": new_item, "quantity": qty_to_add}
			remaining -= qty_to_add
		idx += 1

	inventory_updated.emit()
	return remaining == 0 # complete success - added all items

func remove_item(removed_item: Item, qty: int = 1) -> void:
	pass


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	slots.resize(max_slots)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
