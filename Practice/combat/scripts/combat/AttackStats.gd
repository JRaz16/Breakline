class_name AttackStats
extends Resource
## Base resource class for holding properties common to all attacks

## How much damage the attack does
@export var damage:int = 0
## How much energy this attack costs per use.
@export var energy_cost:int = 0
## How far the attack reaches in pixels.
@export var reach:int = 0
## Delay in seconds before the attack can be initiated again
@export var cooldown:float = 0
## How long the damage-dealing phase of the attack lasts in seconds.
@export var duration:float = 0.5
## How long it takes to activate/wind-up the attack.
@export var activation_time:float = 0
## How much time it takes to follow-through  at the end of attack (character is vulnerable during this time)
@export var recovery_time:float = 0
## How fast this attack moves across the world in pixels per second.
@export var speed:int = 0
