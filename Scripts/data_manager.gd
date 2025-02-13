extends Node

class_name DataManager

static var resources = [[],[],[],[],[]]

var paths = [
	"res://Data/0_Melee/",
	"res://Data/1_Ranged/",
	"res://Data/2_Head/",
	"res://Data/3_Body/",
	"res://Data/4_Consumable/"
]

static var skillResources = []
static var skillPath = "res://Data/Skills/"

static var statusEffectResources = []
static var statusPath = "res://Data/Status_Effect_Buffs/"

static var survivorUpgradeResources = []
static var survivorUpgradePath = "res://Data/Upgrades/Survivor/"

static var weaponUpgradeResources = []
static var weaponUpgradePath = "res://Data/Upgrades/Weapon/"


# populate data by reading files
func _ready():
	var filename
	for i in range(len(paths)):
		var path = paths[i]
		var dir
		dir = DirAccess.open(path)
		dir.list_dir_begin()
		filename = dir.get_next()
		
		while filename != "":
			var fullpath = path + filename
			resources[i].append(load(fullpath))
			filename = dir.get_next()
	
		print("Imported " + str(resources[i].size()) + " resources of type " + ItemType.ReturnString(i))
	
	var dir = DirAccess.open(skillPath)
	dir.list_dir_begin()
	filename = dir.get_next()
	
	while filename != "":
		var fullpath = skillPath + filename
		skillResources.append(load(fullpath))
		filename = dir.get_next()
	
	print("Imported " + str(skillResources.size()) + " skill resources.")
	
	
	dir = DirAccess.open(statusPath)
	dir.list_dir_begin()
	filename = dir.get_next()
	
	while filename != "":
		var fullpath = statusPath + filename
		statusEffectResources.append(load(fullpath))
		filename = dir.get_next()
	
	print("Imported " + str(statusEffectResources.size()) + " status effect resources.")
	

	dir = DirAccess.open(survivorUpgradePath)
	dir.list_dir_begin()
	filename = dir.get_next()
	
	while filename != "":
		var fullpath = survivorUpgradePath + filename
		var newthing = load(fullpath)
		if newthing.disabled != true:
			survivorUpgradeResources.append(newthing)
		filename = dir.get_next()
	
	print("Imported " + str(survivorUpgradeResources.size()) + " survivor upgrade resources.")
	
	
	dir = DirAccess.open(weaponUpgradePath)
	dir.list_dir_begin()
	filename = dir.get_next()
	
	while filename != "":
		var fullpath = weaponUpgradePath + filename
		var newthing = load(fullpath)
		if newthing.disabled != true:
			weaponUpgradeResources.append(newthing)
		filename = dir.get_next()
	
	print("Imported " + str(weaponUpgradeResources.size()) + " weapon upgrade resources.")
