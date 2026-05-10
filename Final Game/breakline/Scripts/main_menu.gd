extends Node2D

var level: int = 1

func _ready() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	var music_bus = AudioServer.get_bus_index("MUSIC")
	var sfx_bus = AudioServer.get_bus_index("SFX")
	
	AudioServer.set_bus_volume_db(master_bus, linear_to_db(0.5)) # 50%
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(0.6))  # 40%
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(0.5))  # 50%
	
	
	$CenterContainer/SettingsMenu/fullscreen.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	$CenterContainer/SettingsMenu/mainvolslider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$CenterContainer/SettingsMenu/musicvolslider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MUSIC")))
	$CenterContainer/SettingsMenu/sfxvolslider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))
	
func _on_play_pressed() -> void:
	GameManager.reset_timer()
	GameManager.start_timer()
	get_tree().change_scene_to_file("res://Scenes/levels/level_1.tscn")


func _on_settings_pressed() -> void:
	$CenterContainer/MainButtons.visible = false
	$CenterContainer/SettingsMenu.visible = true
	$WhiteBackground.visible = false
	$OrangeBackground.visible = true

func _on_credits_pressed() -> void:
	$CenterContainer/MainButtons.visible = false
	$CenterContainer/CreditsMenu.visible = true
	$WhiteBackground.visible = false
	$OrangeBackground.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	$CenterContainer/MainButtons.visible = true
	$CenterContainer/SettingsMenu.visible = false
	$CenterContainer/CreditsMenu.visible = false
	$WhiteBackground.visible = true
	$OrangeBackground.visible = false


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_mainvolslider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_musicvolslider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), value)


func _on_sfxvolslider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
