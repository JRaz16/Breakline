extends Command
class_name DashCommand

func execute(player):

	if player.direction != Vector3.ZERO:
		player.dash_direction = player.direction
	else:
		player.dash_direction = -player.forward

	player.dash_timer = player.DASH_TIME
	player.dash_energy -= player.DASH_COST
	
	EventManager.dash_used.emit()
	
	if player.dash_audio:
		player.dash_audio.pitch_scale = randf_range(0.95, 1.1)
		player.dash_audio.play()
