extends StaticBody2D

class_name PlacedItem

@export var itemType: int = -1
@export var itemID: int = -1


func _ready():
	if itemType < 0 or itemID < 0:
		queue_free()
		print("Error. Item type and ID can't be negative.")


func _to_string():
	var output = "Placed Item\n"
	output += Survivor.ReturnItemData(itemType, itemID).name
		
	return output
