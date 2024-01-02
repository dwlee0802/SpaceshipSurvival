extends Interactable

class_name PlacedItem

@export var itemType: int = -1
@export var itemID: int = -1

var item: Item


func _ready():
	if itemType < 0 or itemID < 0:
		print("Placed item's type and index invalid!")
		queue_free()
		
	if item == null:
		item = Item.new(itemType, itemID)
	else:
		itemType = item.type
		itemID = item.data.ID
	
	$Sprite2D.texture = item.data.texture
	

func _to_string():
	var output = "Placed Item\n"
	output += item.data.name
		
	return output


func Fix(delta):
	return true
