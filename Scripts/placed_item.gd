extends StaticBody2D

class_name PlacedItem

@export var itemType: int = -1
@export var itemID: int = -1

var item: Item


func _ready():
	if item != null:
		itemType = item.type
		itemID = item.ID


func _to_string():
	var output = "Placed Item\n"
	output += Survivor.ReturnItemData(itemType, itemID).name
		
	return output
