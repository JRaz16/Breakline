extends CanvasLayer

@onready var resume = $Control/CenterContainer/MainButtons/resume
@onready var quit = $Control/CenterContainer/MainButtons/quit

func _ready():
	visible = false
	
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	GameManager.pause_menu = self
	
	resume.pressed.connect(_on_resume_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	EventManager.game_resumed.emit()

func _on_quit_pressed():
	get_tree().quit()
