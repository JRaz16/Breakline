class_name CharacterStats
extends Resource


# Character Health
@export var max_health:int = 10

@export var max_energy:int = 10

# Movement Speed
@export var speed: float = 300

@export var energy_recovery:int = 0

@export var health_recovery:int = 0

var invigorated:bool = false


var health: int = max_health:
	set(val):
		health = clampi(val, 0, max_health)

var energy: int = max_energy:
	get():
		if invigorated:
			return max_energy
		return energy
	set(val):
			energy = clampi(val, 0, max_energy)
