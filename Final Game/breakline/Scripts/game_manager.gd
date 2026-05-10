extends Node
# SINGLETON PATTERN

var deaths := 0
var current_level := 1
var current_level_path := ""
var death_screen = null

# SPEEDRUN TIMER
var total_time := 0.0
var timer_running := false

# PAUSE SYSTEM
var pause_menu = null
var paused := false

func _ready():
	EventManager.player_died.connect(_on_player_died)
	EventManager.game_paused.connect(_on_game_paused)
	EventManager.game_resumed.connect(_on_game_resumed)
	EventManager.level_completed.connect(_on_level_completed)

func _process(delta):
	if timer_running:
		total_time += delta

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		var current_scene = get_tree().current_scene.scene_file_path
		
		# Only allow pause in gameplay levels
		
		# EVENT / SIGNAL BUS PATTERN
		# Pause and resume actions are triggered through
		# EventBus signals rather than directly calling
		# pause functions from gameplay objects.
		if current_scene.contains("level_"):
			if paused:
				EventManager.game_resumed.emit()
			else:
				EventManager.game_paused.emit()


func start_timer():
	timer_running = true

func stop_timer():
	timer_running = false

func reset_timer():
	total_time = 0.0

func get_time_string() -> String:
	var minutes = int(total_time / 60)
	var seconds = int(total_time) % 60
	var milliseconds = int((total_time - int(total_time)) * 100)

	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func _on_player_died():
	add_death()
	show_death_screen()
	
func _on_level_completed(path):
	track_level()
	if path == "" or not ResourceLoader.exists(path):
		get_tree().change_scene_to_file("res://Scenes/end_screen.tscn")
		return
	get_tree().change_scene_to_file(path)

func add_death():
	deaths += 1
	
func track_level():
	current_level += 1

func set_current_level(path: String):
	current_level_path = path

func show_death_screen():
	if death_screen:
		death_screen.visible = true
	
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func retry_level():
	get_tree().paused = false
	paused = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	start_timer()

	if current_level_path != "":
		get_tree().change_scene_to_file(current_level_path)

func _on_game_paused():
	paused = true
	get_tree().paused = true
	
	if pause_menu:
		pause_menu.visible = true
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_game_resumed():
	paused = false
	get_tree().paused = false
	
	if pause_menu:
		pause_menu.visible = false
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
