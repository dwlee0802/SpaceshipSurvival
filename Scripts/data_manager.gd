extends Node

class_name DataManager

var item00 = preload("res://Data/0_Melee/0_Fists.tres")
var item01 = preload("res://Data/0_Melee/1_Crowbar.tres")
var item02 = preload("res://Data/0_Melee/2_Fire_Axe.tres")

var item10 = preload("res://Data/1_Ranged/0_Handgun.tres")
var item11 = preload("res://Data/1_Ranged/1_Submachine_Gun.tres")
var item12 = preload("res://Data/1_Ranged/2_Auto_Rifle.tres")
var item13 = preload("res://Data/1_Ranged/3_Laser_Rifle.tres")

var item20 = preload("res://Data/1_Ranged/0_Handgun.tres")

var item30 = preload("res://Data/1_Ranged/0_Handgun.tres")

var item40 = preload("res://Data/3_Body/0_Bulletproof_Vest.tres")

static var resources = [[],[],[],[],[]]

var paths = [
	"res://Data/0_Melee/",
	"res://Data/1_Ranged/",
	"res://Data/2_Head/",
	"res://Data/3_Body/",
	"res://Data/4_Consumable/"
]


# populate data by reading files
func _ready():
	resources[0].append(item00)
	resources[0].append(item01)
	resources[0].append(item02)
	
	resources[1].append(item10)
	resources[1].append(item11)
	resources[1].append(item12)
	resources[1].append(item13)
	
	resources[2].append(item20)
	
	resources[3].append(item30)
	
	resources[4].append(item40)
	
	return
	
	
	for i in range(len(paths)):
		var path = paths[i]
		var dir
		dir = DirAccess.open(path)
		dir.list_dir_begin()
		var filename = dir.get_next()
		
		while filename != "":
			resources[i].append(load(path + filename + ".tres"))
			filename = dir.get_next()
	
		print("Imported " + str(resources[i].size()) + " resources of type " + ItemType.ReturnString(i))
