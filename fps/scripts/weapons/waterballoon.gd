class_name WaterBalloon
extends RigidBody3D

## Enemies within this distance take damage.
@export var splash_radius: float = 10

@onready var sound_fx: AudioStreamPlayer3D = $SoundFX
@onready var timer: Timer = $Timer

func destroy():
	var targets: Array[Node] = get_tree().get_nodes_in_group("target")
	for target in targets:
		var distance_to_target: float = global_transform.origin.distance_to(target.global_transform.origin)
		if distance_to_target <= splash_radius:
			target.queue_free()

func _on_timer_timeout():
	$Shape.visible = false
	sound_fx.play()
	destroy()

func _on_sound_fx_finished():
	queue_free()
