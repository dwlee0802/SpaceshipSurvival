extends Node2D

class_name ItemContainer

var contents = []

var weight: int = 0
var capacity: int = 20

@onready var interactionPoint = $InteractionPoint

@export var randomizeContent: bool = false

@export var spawnAmmo: bool = false
@export var spawnFood: bool = false
@export var spawnWeapons: bool = false
@export var spawnArmor: bool = false
@export var spawnConsumables: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func FillContentsRandomly():
	if randomizeContent:
		var count = randi_range(1,4)
		for i in range(count):
			# pick item type
			var itemType = randi_range(0, 4)
			if itemType == 0:
				AddItem(Item.new(itemType, randi_range(1, len(DataManager.resources[ItemType.Melee]) - 1)))
			if itemType == 1:
				AddItem(Item.new(itemType, randi_range(0, len(DataManager.resources[ItemType.Ranged]) - 1)))
			if itemType == 2:
				AddItem(Item.new(itemType, randi_range(0, len(DataManager.resources[ItemType.Head]) - 1)))
			if itemType == 3:
				AddItem(Item.new(itemType, randi_range(0, len(DataManager.resources[ItemType.Body]) - 1)))
			if itemType == 4:
				AddItem(Item.new(itemType, randi_range(0, len(DataManager.resources[ItemType.Consumable]) - 1)))


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


func _on_timer_timeout():
	FillContentsRandomly()
