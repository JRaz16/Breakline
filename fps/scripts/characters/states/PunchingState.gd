class_name PunchingState
extends NPCState
## Governs the behavior of an NPC attempting to engage in melee combat.


@export_range(1, 2) var punch_range: float = 1.5

var can_punch: bool = true
var punch_timer:Timer


func enter():
	npc.sound_fx.stream = npc.punch_sound
	npc.watergun.hide()
	super.enter()


func exit(): super.exit()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "Punching"
	animator.get_animation(animation).loop_mode = Animation.LOOP_NONE
	punch_timer = Timer.new()
	punch_timer.wait_time = animator.get_animation(animation).length #4.75
	punch_timer.timeout.connect(func(): can_punch = true)
	add_child(punch_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	npc.orient()

	var target_pos: Vector3 = npc.target.global_transform.origin
	var npc_pos: Vector3          = npc.global_transform.origin
	var distance_to_target: float = (target_pos - npc_pos).length()

	if can_punch && distance_to_target <= punch_range:
		can_punch = false
		punch_timer.start()
		animator.seek(0)
		animator.play()
		npc.sound_fx.play()
		await get_tree().create_timer(0.5).timeout
		npc.target.got_hit()
	elif distance_to_target > 2 * punch_range:
		npc.change_state(get_node(^"../Chasing"))


# Called every physics tick. 'delta' is the elapsed time since the previous tick.
func _physics_process(_delta): pass
