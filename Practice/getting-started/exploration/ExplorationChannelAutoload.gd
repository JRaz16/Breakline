class_name ExplorationChannelAutoload
extends Node

##var discoveries:Dictionary = {
##	"items": []
##}

@warning_ignore("unused_signal")
signal region_entered(region:Node)

@warning_ignore("unused_signal")
signal region_exited(region:Node)

static var instance:ExplorationChannelAutoload:
	get: return instance
	set(new_instance):
		assert(instance == null)
		instance = new_instance

#static var _instance:ExplorationChannelAutoload = null

#static func get_instance() -> ExplorationChannelAutoload:
#	if _instance == null:
#		return ExplorationChannelAutoload.new()
#	return _instance

func _init() -> void:
	#assert(instance == null)
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
