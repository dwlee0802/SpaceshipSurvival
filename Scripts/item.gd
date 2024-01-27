extends Node

class_name Item

var type: int = -1
var data: Weapon
static var itemDict

func _init(_type, _id):
	type = _type
	
	if _id >= len(DataManager.resources[type]):
		print("ERROR! ID out of bounds.")
		print(str(_id) + " for " + str(type))
	else:
		data = DataManager.resources[type][_id]


func _to_string():
	var output = data.name + "\n"
	output += data.description
	return output
