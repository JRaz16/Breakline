extends Control


@onready var final_time = $FinalTimeLabel

func _ready():
	final_time.text = "Final Time: " + GameManager.get_time_string()
