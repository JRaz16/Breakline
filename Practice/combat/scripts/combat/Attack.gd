class_name Attack
extends Area2D
## Base class for all attacks that a character can make

## Properties for this attack
@export var stats:AttackStats

## Direction of movement, if any, for this attack.
var velocity:Vector2 = Vector2.ZERO


## Initialize the position and velocity for this attack.
## Intended for use only with ranged attacks.
func spawn(origin:Vector2, angle:float) -> void:
	global_position = origin
	self.rotation = angle
	velocity = stats.speed * Vector2.RIGHT.rotated(angle)
	print(velocity)


## Initial phase of an attack (e.g., wind-up, charging, etc.).
func activate():
	self.visible = true
	# TODO implement activation time delay is desired
	execute()

## Main damage-dealing phase of an attack.
func execute():
	$Detector.disabled = false
	# TODO implement an attack duration delay
	await get_tree().create_timer(stats.duration).timeout
	$Detector.disabled = true
	recover()


## Final phase of an attack (e.g., follow-through, return-to-ready, etc.).
func recover():
	# TODO implement recovery time delay if desired
	self.visible = false


func _ready() -> void:
	self.visible = false
	$Detector.disabled = true


func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	global_position += velocity * delta # melee attacks have zero velocity


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"enemy"):
		body.take_hit(stats.damage)


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
