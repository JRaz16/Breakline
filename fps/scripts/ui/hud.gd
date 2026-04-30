class_name HUD
extends CanvasLayer

@onready var message_timer: Timer = get_node(^"MessageTimer")
@onready var score_label: Label = get_node(^"Score")
@onready var screen_flash: ScreenFlash = get_node(^"ScreenFlash")
@onready var lives_label: Label = get_node(^"Lives")
@onready var health_label: Label = get_node(^"Health")
@onready var user_message: Label = get_node(^"Message")


# Called when the node enters the scene tree for the first time.
func _ready():
	user_message.text = ""
	message_timer.wait_time = 5


func _on_message_timer_timeout():
	user_message.text = ""
	message_timer.stop()


func _on_player_item_collected(item_name: String):
	user_message.text = "You collected " + item_name
	message_timer.start()


func _on_player_score_changed(score: int):
	score_label.text = str(score)


func _on_player_health_changed(health: float):
	health_label.text = "Dryness: " + str(health)
	screen_flash.start_fade()


func _on_player_lives_changed(lives: float):
	lives_label.text = "Lives: " + str(lives)


func _on_player_inventory_changed(inventory: WeaponInventory):
	var message = inventory.get_curr_weapon_name()
	message += "(" + str(inventory.get_curr_weapon_ammo()) + ")"
	user_message.text = message
