class_name IdleState
extends NPCState
## Governs the behavior of a character who is not doing anything.


func enter(): super.enter()


func exit(): super.exit()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "IDLE"
	animator.get_animation(animation).loop_mode = Animation.LOOP_LINEAR


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if npc.target:
		npc.change_state(get_node(^"../Shooting"))


func _physics_process(_delta):
	npc.look_for_player()
