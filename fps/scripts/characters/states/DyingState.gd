class_name DyingState
extends NPCState
## Governs what happens when the controlled character dies.


func enter(): super.enter()


func exit(): super.exit()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "Dying"
	animator.get_animation(animation).loop_mode = Animation.LOOP_NONE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): pass


## Signal callback to remove this character from the scene tree after death.
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Dying":
		npc.queue_free()


## Ignore subsequent hits if already dying
func _on_hit(): pass
