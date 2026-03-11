class_name Item extends Resource

@export var name:String = "Unknown Item"
@export var description:String = ""
@export var icon:Texture2D
@export var is_stackable:bool = true
@export var max_stack:int = 64

func use(player:Node) -> void:
	print("Player used" + self.name + "!")
