class_name Hive extends Sprite2D
## A hive by and for bees.

## How much nectar is stored at this hive.
@export var nectar:int = 0


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
