class_name Character
extends CharacterBody2D
## Base class for all game characters, whether player or AI-controlled.

## Movement rate for the character in pixels per second.
@export var stats: CharacterStats

@export var attacks:Array[Attack] = []

var current_attack:int = 0

#@export var melee_attack:PackedScene = preload("res://scenes/combat/melee_attack.tscn")
#@export var ranged_attack:PackedScene = preload("res://scenes/combat/ranged_attack.tscn")

#@onready var melee:Attack = melee_attack.instantiate()

func attack():
	if attacks[current_attack].stats.energy_cost > stats.energy:
		return
	stats.energy -= attacks[current_attack].stats.energy_cost
	attacks[current_attack].activate()
	
#func shoot():
	#var projectile:Attack = ranged_attack.instantiate()
	#if projectile.stats.energy_cost > stats.energy:
		#projectile.queue_free()
		#return
		#
	#projectile.spawn($AttackOrigin.global_position, self.rotation)
	#stats.energy -= projectile.stats.energy_cost
	#get_parent().add_child(projectile)
	#projectile.activate()
	#
func take_hit(damage:int):
	stats.health -= damage
	if stats.health <= 0:
		queue_free()

func _ready():
	#melee = melee_attack.instantiate()
	#$AttackOrigin.add_child(melee)
	stats.health = stats.max_health
	stats.energy = stats.max_energy


func _process(_delta):
	pass


func _physics_process(delta):
	move_and_collide(velocity * delta)
