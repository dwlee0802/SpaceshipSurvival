extends Node

class_name Item

var type: int = -1
var data
static var itemDict

func _init(_type, _id):
	type = _type
	
	if type == ItemType.Melee:
		data = itemDict.Melee[_id]
	elif type == ItemType.Ranged:
		data = itemDict.Ranged[_id]
	elif type == ItemType.Head:
		data = itemDict.Head[_id]
	elif type == ItemType.Body:
		data = itemDict.Body[_id]
	elif type == ItemType.Consumable:
		data = itemDict.Consumable[_id]

func _to_string():
	var output = data.name + "\n"
	output += "Type: " + str(type) + "\nID: " + str(data.ID)
	return output
