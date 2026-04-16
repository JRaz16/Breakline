class_name Quest extends Resource


## the various states a quest can be in
enum Status {
	PENDING = -1,
	UNLOCKED,
	ACCEPTED,
	COMPLETED,
	REWARDED
}

## Descriptive title for the quest
@export var name:StringName

## How many coins are rewarded for completing a quest
@export_range(0,1000) var reward:int

## Indicates current status of quests
@export var status:Status = Status.PENDING:
	set(new_status):
		status = new_status
		match status:
			Status.UNLOCKED:
				QuestChannel.quest_unlocked.emit(self)
			Status.ACCEPTED:
				QuestChannel.quest_accepted.emit(self)
			Status.COMPLETED:
				QuestChannel.quest_completed.emit(self)
			Status.REWARDED:
				QuestChannel.quest_rewarded.emit(self)


## Unique Identifier for quests
var uid:int

func ready():
	status = status

func _unlock():
	print("Quest '", name, "' unlocked!")
	status = Status.UNLOCKED
	
func _accepted():
	print("Quest '", name, "' accepted!")
	status = Status.ACCEPTED

func _complete():
	print("Quest '", name, "' completed!")
	status = Status.COMPLETED
	
func _rewarded():
	print("Quest '", name, "' rewarded!")
	status = Status.REWARDED
