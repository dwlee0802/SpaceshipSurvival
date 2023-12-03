extends Node2D

class_name ItemContainer

var contents = []

var weight: int = 0
var capacity: int = 20

@onready var interactionPoint = $InteractionPoint


# Called when the node enters the scene tree for the first time.
func _ready():
	AddItem(Item.new(0,0))
	AddItem(Item.new(1,0))
	AddItem(Item.new(2,0))


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
