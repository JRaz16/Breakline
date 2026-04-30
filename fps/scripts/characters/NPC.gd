class_name NPC
extends CharacterBody3D
## Simple state-machine driven enemy AI

@export_group("Attributes")

## Damage this character can take before dying.
@export_range(1, 100) var health: int = 100

## Speed when walking in meters per sec.
@export_range(1, 10) var walk_speed: float = 3

## Speed when running in meters per sec.
@export_range(1, 10) var run_speed: float = 6

@export_group("State Machine")

## Initial state for this character.
@export var current_state: NPCState

@export_group("Sound FX")

## Sound played when this character punches
@export var punch_sound: AudioStream

## Sound played when this character shoots
@export var shoot_sound: AudioStream

# Embedded agent used for pathfinding on navigation mesh surfaces.
@onready var nav_agent: NavigationAgent3D = get_node(^"NavigationAgent3D")

# Weapon instance attached to the hand bone of this character's skeleton.
@onready var watergun: Node = get_node(^"Avatar/IDLE/Skeleton3D/RightHand/watergun")

# Ray cast for performing line-of-sight determinations.
@onready var line_of_sight: RayCast3D = get_node(^"LineOfSight")

# Spatial audio player
@onready var sound_fx: AudioStreamPlayer3D = get_node(^"SoundFX")

var can_see_player: bool = false
var target: CharacterBody3D


## Gracefully change states by exiting the current state before entering a new one.
func change_state(new_state: NPCState):
	print("Changing state")
	if current_state: current_state.exit()
	current_state = new_state
	current_state.enter()


## Inflict damage on this character delivered by another character.
func got_hit_by(other: Node3D) -> void:
	if health == 0: return
	health = max(health - 20, 0)
	print("Enemy health = ", health)
	if health > 0:
		target = other
		change_state($States/Hit)
	else:
		change_state($States/Dying)


## Determine whether this character can see the player.
func look_for_player() -> bool:
	if line_of_sight.is_colliding():
		var obj: Node = line_of_sight.get_collider()
		if obj.is_in_group("player"):
			target = obj
			can_see_player = true
			return true
	can_see_player = false
	return false


## Convenience function for stopping this character's movement.
func stop():
	velocity = Vector3.ZERO


# Called when the node enters the scene tree for the first time.
func _ready():
	assert(current_state != null, "You must assign an initial state in the Inspector!")
	current_state = get_node(^"States/Idling")
	# These values need to be adjusted for the actor's speed and the navigation layout.
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	# Wait for first physics frame so the NavigationServer can sync.
	await get_tree().physics_frame
	change_state.call_deferred($States/Patrolling)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta): pass


# Face target or direction of movement
func orient():
	if target:
		look_at(target.global_position, Vector3.UP)
	elif not velocity.is_zero_approx():
		look_at(transform.origin + velocity, Vector3.UP)


# Called every physics tick. 'delta' is the elapsed time since the previous tick.
func _physics_process(_delta):
	move_and_slide()


## Signal callback to ensure obstacle avoidance during navigation.
func _on_velocity_computed(safe_velocity: Vector3):
	velocity = safe_velocity
