class_name QuestJournal extends CanvasLayer


@export var icons:Array[Texture2D]

@export var colors:Array[Color]

@onready var quest_chooser:ItemList

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_quest_journal"):
		get_viewport().set_input_as_handled()
		self.close()

func add_quest(quest:Quest):
	quest_chooser.add_item(quest.name, icons[quest.status])
	quest_chooser.set_item_custom_fg_color(quest_chooser.item_count - 1, colors[quest.status])

func update_quest(quest:Quest):
	for i in quest_chooser.item_count:
		if quest_chooser.get_item_text(i) == quest.name:
			quest_chooser.set_item_icon(i, icons[quest.status])
			quest_chooser.set_item_custom_fg_color(i, colors[quest.status])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.visible = false
	QuestChannel.quest_accepted.connect(update_quest)
	
	QuestChannel.quest_completed.connect(update_quest)
	
	QuestChannel.quest_rewarded.connect(update_quest)
	
	QuestChannel.quest_unlocked.connect(add_quest)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open() -> void:
	get_tree().paused = true
	self.visible = true

func close() -> void:
	self.visible = false
	get_tree().paused = false
