class_name ShootingState
extends NPCState
## Governs the behavior of an NPC attempting to engage in ranged combat.

## How many times per second can the character shoot.
@export_range(0.1, 10) var shoot_rate:float = 1.0

var can_shoot:bool = true
var shoot_timer:Timer


func enter():
	print("ENTER STATE: Shooting")
	npc.sound_fx.stream = npc.shoot_sound
	npc.watergun.show()
	super.enter()


func exit():
	print("EXIT STATE: Shooting")
	super.exit()
	npc.watergun.hide()


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if animation.is_empty(): animation = "Shooting"
	shoot_timer = Timer.new()
	shoot_timer.wait_time = 1 / shoot_rate
	shoot_timer.timeout.connect(func(): can_shoot = true)
	add_child(shoot_timer)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	npc.orient()

	var distance_to_player: Vector3 = npc.target.global_transform.origin - npc.global_transform.origin
	if distance_to_player.length() < 1.5:
		npc.change_state(get_node(^"../Punching"))
	elif can_shoot:
		can_shoot = false
		shoot_timer.start()
		animator.play()
		npc.sound_fx.play()
		await animator.animation_finished


# Called every physics tick. 'delta' is the elapsed time since the previous tick.
func _physics_process(_delta):
	if not npc.look_for_player():
		npc.change_state(get_node(^"../Chasing"))


# Handle input events
func _input(event):
	if event.is_action_pressed("patrol"):
		npc.change_state(get_node(^"../Patrolling"))


func _on_shoot():
	print("shot player")
	npc.target.got_hit()
