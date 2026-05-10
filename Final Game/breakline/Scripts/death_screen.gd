extends CanvasLayer

@onready var retry = $CenterContainer/EndMenu/Retry
@onready var quit = $CenterContainer/EndMenu/Quit

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	GameManager.death_screen = self
	
	visible = false
	
	retry.pressed.connect(_on_retry_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _on_retry_pressed():
	GameManager.retry_level()

func _on_quit_pressed():
	get_tree().quit()
