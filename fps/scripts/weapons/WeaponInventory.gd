class_name WeaponInventory

var weapons: Array[Variant] = []
var weapon_index:int        = 0

func _init():
	weapons.append(Weapon.new(Weapon.TYPE_GUN))
	weapons.append(Weapon.new(Weapon.TYPE_AUTO_GUN))
	weapons.append(Weapon.new(Weapon.TYPE_GRENADE))

func change_weapon():
	weapon_index += 1
	if weapon_index > 2: weapon_index = 0

func has_ammo_for_current() -> bool:
	return weapons[weapon_index].ammo > 0

func decrease_curr_ammo(amount:int = 1):
	weapons[weapon_index].decrease_ammo(amount)
	
func get_curr_reload_time() -> float:
	return weapons[weapon_index].reload_time
	
func get_curr_weapon_name() -> String:
	return weapons[weapon_index].name

func get_curr_weapon_ammo() -> int:
	return weapons[weapon_index].ammo
