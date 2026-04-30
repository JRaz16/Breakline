class_name Flower extends Area2D
## A flower containing nectar

const DEFAULT_NECTAR:int = 2

## The current amount of nectar available at this flower.
@export var nectar:int = DEFAULT_NECTAR


## Collect and remov one unit of nectar from this flower.
func collect() -> int:
	if nectar > 0:
		nectar -= 1
		return 1
	return 0


## Check whether this flower has run out of nectar
func is_depleted():
	return nectar <= 0


## Collect all necessary save data into a dictionary.
func save_data() -> Dictionary:
	var data:Dictionary = {
		"nectar": self.nectar,
		"position": self.position
	}
	return data

## Restore the values of save properties from a dictionary.
func load_data(data:Dictionary) -> void:
	self.nectar = data["nectar"]
	self.position = Util.str_to_vec2(data["position"])
