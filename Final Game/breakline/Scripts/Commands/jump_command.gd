extends Command
class_name JumpCommand

func execute(player):

	if player.is_on_floor():
		player.velocity.y = player.JUMP_VELOCITY
		print("jumping")
