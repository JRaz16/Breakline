class_name ExploreQuest extends Quest


@export var places:Array[String]

func _accepted():
	ExplorationChannel.region_entered.connect(_on_region_entered)
	super._accepted()
	
	
func _complete():
	ExplorationChannel.region_entered.disconnect(_on_region_entered)
	super._complete()
	
	
func _on_region_entered(region:Region):
	places.erase(region.name)
	if places.is_empty():
		_complete()
