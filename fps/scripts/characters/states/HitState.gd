class_name HitState
extends NPCState
## Governs what happens when the controlled character has been hit.


func enter():
	print("ENTER STATE: Hit")
	animator.seek(0)
	super.enter()


func exit():
	print("EXIT STATE: Hit")
	super.exit()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "Hit"
	animator.get_animation(animation).loop_mode = Animation.LOOP_NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): pass


## Signal callback to respond to a hit by shooting the target.
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Hit":
		npc.change_state(get_node(^"../Shooting"))
