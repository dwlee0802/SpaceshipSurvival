extends Node2D

class_name ItemContainer

var contents = []

var weight: int = 0
var capacity: int = 20

@onready var interactionPoint = $InteractionPoint

@export var randomizeContent: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if randomizeContent:
		var count = randi_range(1,4)
		for i in range(count):
			# pick item type
			var itemType = randi_range(0, 4)
			if itemType == 0:
				AddItem(Item.new(itemType, randi_range(0, 1)))
			if itemType == 1:
				AddItem(Item.new(itemType, randi_range(0, 1)))
			if itemType == 2:
				AddItem(Item.new(itemType, randi_range(0, 1)))
			if itemType == 3:
				AddItem(Item.new(itemType, randi_range(0, 1)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func AddItem(item: Item):
	if weight + item.data.weight <= capacity:
		contents.append(item)
		UpdateWeight()
		return true
	else:
		return false
	

func RemoveItemByIndex(index):
	var removed = contents.pop_at(index)
	UpdateWeight()
	return removed


func UpdateWeight():
	weight = 0
	for item in contents:
		weight += item.data.weight
