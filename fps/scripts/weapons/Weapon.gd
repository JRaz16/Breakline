class_name Weapon

const TYPE_GUN:int = 0
const TYPE_AUTO_GUN:int = 1
const TYPE_GRENADE:int = 2
var reload_time:float
var name:String
var ammo:int
var max_ammo:int

func _init(weapon_type:int = TYPE_GUN):
	match weapon_type:
		TYPE_GUN:
			name = "SQUIRT"
			reload_time = 2
			ammo = 10
			max_ammo = 20
		TYPE_AUTO_GUN:
			name = "RAPID SQUIRT"
			reload_time = 0.5
			ammo = 20
			max_ammo = 20
		TYPE_GRENADE:
			name = "WATER BALLOON"
			reload_time = 3
			ammo = 1
			max_ammo = 5
	print("Created weapon type: ", weapon_type)

func increase_ammo(ammo_increase:int = 1):
	ammo = min(ammo + ammo_increase, max_ammo)

func decrease_ammo(ammo_decrease:int = 1):
	ammo = max(ammo - ammo_decrease, 0)
