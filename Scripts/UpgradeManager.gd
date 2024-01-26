extends Node
class_name UpgradeManager

# keeps track of the weapon upgrades selected

# holds array of upgrade resources for each weapon type
# first id is the weapon ID
static var melee_upgrades = []
static var ranged_upgrades = []


# make empty arrays to hold upgrades for each weapon type
static func _static_init():
	for i in range(len(DataManager.resources[ItemType.Melee])):
		var newlist = []
		melee_upgrades.append(newlist)
		
	for i in range(len(DataManager.resources[ItemType.Ranged])):
		var newlist = []
		ranged_upgrades.append(newlist)


static func AddUpgrade(weaponType, weaponID, upgrade):
	if weaponType == ItemType.Melee:
		melee_upgrades[weaponID].append(upgrade)
	elif weaponType == ItemType.Ranged:
		ranged_upgrades[weaponID].append(upgrade)
