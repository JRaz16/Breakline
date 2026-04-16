class_name NPC extends Area2D


@export var quest:Quest


func talk(body:Node):
	if body is Player2D:
		match quest.status:
			Quest.Status.PENDING:
				quest._unlock()
			Quest.Status.UNLOCKED:
				quest._accepted()
			Quest.Status.COMPLETED:
				quest._rewarded()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quest.ready() # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
