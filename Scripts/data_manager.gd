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


# populate data by reading files
func _ready():
	for i in range(len(paths)):
		var path = paths[i]
		var dir
		dir = DirAccess.open(path)
		dir.list_dir_begin()
		var filename = dir.get_next()
		
		while filename != "":
			var fullpath = path + filename
			resources[i].append(load(fullpath))
			filename = dir.get_next()
	
		print("Imported " + str(resources[i].size()) + " resources of type " + ItemType.ReturnString(i))
	
	var dir = DirAccess.open(skillPath)
	dir.list_dir_begin()
	var filename = dir.get_next()
	
	while filename != "":
		var fullpath = skillPath + filename
		skillResources.append(load(fullpath))
		filename = dir.get_next()
	
	print("Imported " + str(skillResources.size()) + " skill resources.")
