class_name ScreenFlash
extends ColorRect

var alpha: float = 0
var fade_timer: Timer


# Called when the node enters the scene tree for the first time.
func _ready():
	color.a = alpha
	fade_timer = Timer.new()
	fade_timer.wait_time = 0.1
	fade_timer.timeout.connect(decrease_alpha)
	add_child(fade_timer)


func start_fade():
	alpha = 1
	fade_timer.start()


func decrease_alpha():
	alpha -= 0.1
	if alpha <= 0:
		alpha = 0
		fade_timer.stop()
	color.a = alpha
