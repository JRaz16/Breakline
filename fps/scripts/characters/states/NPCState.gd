class_name NPCState
extends Node
## Base class for all non-player character states


## You must provide a reference to an NPC node in the scene tree.
@export var npc: NPC
## Override this to specify a custom animation for this state.
@export var animation: String = ""
## Override this to speed up or slow down the animations of this state.
@export var anim_speed: float = 1
## You must provide a reference to a node with animations for this character.
@export var animator: AnimationPlayer = null


## Transition into this state
func enter():
	animator.play(animation)
	animator.speed_scale = anim_speed
	process_mode = PROCESS_MODE_INHERIT


## Transition out of this state
func exit():
	process_mode = PROCESS_MODE_DISABLED


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(npc != null, "Use Inspector to assign a CharacterBody3D to control!")
	if not animator:
		animator = npc.get_node("Avatar/AnimationPlayer")
	animator.animation_finished.connect(_on_animation_player_animation_finished)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): pass


# Called every tick of the physics subsystem. 'delta' is the elapsed time since the previous tick.
func _physics_process(_delta): pass


# Handle input events
func _input(_event): pass


## Signal callback for managing animations in this state.
func _on_animation_player_animation_finished(_anim_name): pass


## Signal callback for handling getting hit while in almost any state.
## Note: override this to ignore a hit or do something else.
func _on_hit():
	npc.change_state(get_node(^"$../Hit"))
