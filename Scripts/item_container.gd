extends Interactable

class_name ItemContainer

static var resourceOrb = preload("res://Scenes/resouce_orb.tscn")

var contents = []

var weight: int = 0
var capacity: int = 20

@export var randomizeContent: bool = true

@export var randomizeContentAmount: int = true

@export var spawnAmmo: bool = false
@export var spawnFood: bool = false
@export var spawnComponents: bool = false
@export var spawnWeapons: bool = false
@export var spawnArmor: bool = false
@export var spawnConsumables: bool = false

var opened: bool = false

@export var opened_texture: Texture
@export var closed_texture : Texture

static var MAX_ITEM_COUNT: int = 4
static var MAX_RESOURCE_COUNT: int = 10

# sound
@onready var audioPlayer: AudioStreamPlayer = $AudioStreamPlayer


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if available:
		modulate = Color.GREEN
	else:
		modulate = Color.WHITE
		
	available = false


func FillContentsRandomly():
	if randomizeContent:
		var count = randi_range(1, ItemContainer.MAX_ITEM_COUNT)
		var options = []
		if spawnWeapons:
			options.append(ItemType.Ranged)
			options.append(ItemType.Melee)
		if spawnArmor:
			options.append(ItemType.Head)
			options.append(ItemType.Body)
		if spawnConsumables:
			options.append(ItemType.Consumable)
			
		for i in range(count):
			# pick item type
			var itemType = options.pick_random()
			
			if itemType == 0:
				# excluding fists(0,0)
				AddItem(Item.new(itemType, randi_range(1, len(DataManager.resources[ItemType.Melee]) - 1)))
			else:
				AddItem(Item.new(itemType, randi_range(0, len(DataManager.resources[itemType]) - 1)))

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


func Fix(delta):
	if opened == false:
		$Sprite2D.texture = opened_texture
		opened = true
		SpawnResources()
		audioPlayer.play()
	return true


# spawns and disperses resource orbs when it is first opened
func SpawnResources():
	var amount = randi_range(0, MAX_RESOURCE_COUNT)
	for i in range(amount):
		var newOrb = resourceOrb.instantiate()
		get_tree().root.add_child(newOrb)
		newOrb.position = global_position
		newOrb.target_position = global_position + Vector2(randi_range(-50, 50), randi_range(-50, 50))
