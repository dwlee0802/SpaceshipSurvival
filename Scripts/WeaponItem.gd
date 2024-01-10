extends Item
class_name Gun

var totalAmmo: int
var currentAmmo: int

func _init(_type, _id):
	super._init(_type, _id)
	if data is RangedWeapon:
		totalAmmo = data.totalAmmo - data.magazineCapacity
		currentAmmo = data.magazineCapacity
	else:
		print("ERROR! Non ranged weapon data in Gun object")
	

func Shoot():
	if currentAmmo > 0 and not data.isLaserWeapon:
		currentAmmo -= 1
		return true
	else:
		return false


func Reload():
	if totalAmmo <= 0:
		return
		
	var need = data.magazineCapacity - currentAmmo
	if totalAmmo >= need:
		currentAmmo += need
		totalAmmo -= need
	else:
		currentAmmo += totalAmmo
		totalAmmo = 0


func RefillAmmo():
	totalAmmo = data.totalAmmo
	
	
func _to_string():
	return super._to_string() + "\n" + str(Game.survivor.primarySlot.currentAmmo) + " / " + str(Game.survivor.primarySlot.data.magazineCapacity) + " (" + str(Game.survivor.primarySlot.totalAmmo) + ")"
