extends Item
class_name Gun

var totalAmmo: int
var currentAmmo: int

func _init(_type, _id):
	super._init(_type, _id)
	if data is RangedWeapon:
		totalAmmo = data.totalAmmo
		currentAmmo = data.magazineCapacity
	else:
		print("ERROR! Non ranged weapon data in Gun object")
	

func Shoot():
	if currentAmmo > 0:
		currentAmmo -= 1
		return true
	else:
		return false


func Reload():
	if totalAmmo >= data.magazineCapacity:
		currentAmmo = data.magazineCapacity
		totalAmmo -= data.magazineCapacity
	else:
		currentAmmo = totalAmmo
		totalAmmo = 0


func RefillAmmo():
	totalAmmo = data.totalAmmo
