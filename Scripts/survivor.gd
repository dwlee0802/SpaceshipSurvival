extends "res://Scripts/unit.gd"

class_name Survivor

var endAccuracy: float = 0

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine

@onready var selectionCircle = $SelectionCircle

static var itemsFilePath: String = "res://Data/Items.json"
static var itemsDict

@onready var attackTimer = $AttackTimer
@onready var attackRaycast = $AttackRaycast

@onready var armSprite = $ArmSprite
@onready var muzzleFlashSprite = $ArmSprite/MuzzleFlash

@onready var noAmmoLabel = $NoAmmoLabel

@onready var destinationMarker = $DestinationCircle
@onready var attackTargetMarker = $AttackTargetUI

var interactionTarget

var interactionContainer

# Holds the itemIDs that the player has in its inventory
var inventory = []

# Holds the index inside inventory of equipped gear
# 0: Head slot, 1: Body slot, 2: primary weapon slot, 3: secondary weapon slot
# -1 itemID means slot is empty
var equipmentSlots = [-1, -1, -1, -1, -1]

# how heavy the items this unit is carrying is
# heavier the load, the slower the unit can move
# if weight exceeds capacity, speed is reduced
var inventoryWeight: int = 0
var inventoryCapacity: int = 20


# unit stats

# modifies reload time
var reloadSpeed: float = 1

# oxygen level in body. Starts to lose health when it reaches zero
var oxygen: float = 100

var bodyTemperature: float = 36.5

var nutrition: float = 100

# how strong this person is. Affects melee damage and inventory capacity
# 2 inventory cap for 1 strength
var strength: int = 10

var sleep: float = 600

var isDead: bool = false


# Combat Behavior
var moveAndShoot: bool = true
var fireAtWill: bool = true

# survivors join the player's team by being rescued.
var needsRescue: bool = true

signal update_unit_ui


func _ready():
	super._ready()
	# read in json files
	var file1 = FileAccess.open(itemsFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	itemsDict = parse_json(content_as_text1)
	Item.itemDict = itemsDict
	
	attackTimer.timeout.connect(Attack)
	
	UpdateStats()
	
	$AttackUpdateTimer.timeout.connect(ScanForAttackTargets)
	
	destinationMarker.get_node("Label").text = name
	
	overviewMarker.self_modulate = Color.GREEN
	

func parse_json(text):
	return JSON.parse_string(text)


func _process(delta):
	if isDead:
		return
		
	oxygen -= delta * 3
	if oxygen < 0:
		oxygen = 0
	if oxygen == 0:
		health -= delta
		
	sleep -= delta
	
	nutrition -= delta
	if nutrition < 0:
		nutrition = 0
	if nutrition == 0:
		health -= delta
	
	# high fever
	if bodyTemperature >= 42:
		health -= delta * 2
	# moderate fever
	elif bodyTemperature >= 40:
		health -= delta * 0.5
	# mild fever
	elif bodyTemperature >= 38:
		pass
	
	# Severe Hypothermia
	if bodyTemperature <= 28:
		health -= delta * 2
	# moderate Hypothermia
	elif bodyTemperature <= 32:
		health -= delta * 0.5
	# mild Hypothermia
	elif bodyTemperature <= 34:
		pass
	
	UpdateHealthBar()
	

func _physics_process(delta):
	if isDead:
		return
		
	super._physics_process(delta)
	muzzleFlashSprite.visible = false
	
	if not isMoving:
		destinationMarker.visible = false
	else:
		destinationMarker.visible = true
		destinationMarker.position = target_position - position
	
	if attackTarget != null and not attackTimer.is_stopped():
		attackTargetMarker.visible = true
		attackTargetMarker.global_position = attackTarget.global_position
	else:
		attackTargetMarker.visible = false
		
	if  (not isMoving) and (interactionTarget != null):
		if interactionTarget is Interactable:
			if interactionTarget.Fix(delta):
				interactionTarget = null
			else:
				PointArmAt(interactionTarget.global_position)
		if interactionTarget is PlacedItem:
			# pick up item
			print(interactionTarget)
			AddItemByIndex(interactionTarget.itemType, interactionTarget.itemID)
			interactionTarget.queue_free()
			interactionTarget = null
			emit_signal("update_unit_ui")
		if interactionTarget is ItemContainer:
			interactionContainer = interactionTarget
			interactionTarget = null
			emit_signal("update_unit_ui")
			
	
	if fireAtWill:
		if attackTarget != null and (moveAndShoot or (not moveAndShoot and not isMoving)):
			attackRaycast.target_position = attackTarget.position - position
			if attackRaycast.get_collider() == null:
				if attackTimer.is_stopped():
					attackTimer.start()
				PointArmAt(attackTarget.position)
				SetAttackLine()
			else:
				attackTimer.stop()
				attackLine.visible = false
		else:
			# line of sight blocked. cant attack
			attackTimer.stop()
			attackLine.visible = false
		
		
func ScanForAttackTargets():
	# acquire attack targets
	var targets = attackArea.get_overlapping_bodies()
	attackTarget = null
			
	if len(targets) == 0:
		attackLine.visible = false
	else:
		# find closest target
		var minDist = 10000
		for item in targets:
			# only consider those within line of sight
			var dist = position.distance_to(item.position)
			if dist < minDist:
				minDist = dist
				attackTarget = item
				var text = "Hit Chance: " + str(int(endAccuracy * 100 - attackTarget.evasion * 100)) + "\n"
				text += "ACC: " + str(int(endAccuracy * 100)) + "\n"
				text += "EVA: " + str(int(attackTarget.evasion * 100)) + "\n"
				attackTargetMarker.get_node("Label").text = text
		
		attackRaycast.target_position = attackTarget.position - position


func Attack():
	# deal damage
	# default weapon fists
	var primary = Item.new(0,2)
	if equipmentSlots[SlotType.Primary] >= 0:
		primary= inventory[equipmentSlots[SlotType.Primary]]
	if Spaceship.ConsumeAmmo(primary.data.ammoPerShot):
		var amount = randi_range(primary.data.damageMin, primary.data.damageMax)
		if is_instance_valid(attackTarget):
			attackTarget.ReceiveHit(amount, primary.data.penetration, endAccuracy)
		else:
			attackTarget = null
		#print("Delt ", str(amount), " damage!")
		muzzleFlashSprite.visible = true
		noAmmoLabel.visible = false
	else:
		noAmmoLabel.visible = true


# takes in where, which slot to put item into, and what, which is the index of the item being moved inside inventory.
func EquipItemFromInventory(what: int, where: int):
	equipmentSlots[where] = what
	

func EquipNewItem(item: Item, where: int):
	inventory.append(item)
	equipmentSlots[where] = inventory.find(item)
	inventoryWeight += item.data.weight
	UpdateStats()


func UpdateStats():
	# equip fists as default
	var primary = Item.new(0,2)
	if equipmentSlots[SlotType.Primary] >= 0:
		primary = inventory[equipmentSlots[SlotType.Primary]]
	var head = null
	if equipmentSlots[SlotType.Head] >= 0:
		head = inventory[equipmentSlots[SlotType.Head]]
	var body = null
	if equipmentSlots[SlotType.Body] >= 0:
		body = inventory[equipmentSlots[SlotType.Body]]
	
	if primary != null:
		attackTimer.wait_time = 1 / primary.data.attacksPerSecond
		get_node("AttackArea").get_node("CollisionShape2D").shape.set_radius(primary.data.range)
		endAccuracy = accuracy + primary.data.accuracy
	
	defense = 0
	radiationDefense = 0
	if head != null:
		defense += head.data.defense
		radiationDefense += head.data.radiationDefense
	
	if body != null:
		defense += body.data.defense
		radiationDefense += body.data.radiationDefense
	
	inventoryCapacity = strength * 2

	# modify speed based on inventory weight
	if inventoryWeight > inventoryCapacity:
		speedModifier = 1 - (inventoryWeight - inventoryCapacity) / float(inventoryCapacity)
		if speedModifier < 0:
			speedModifier = 0
	else:
		speedModifier = 1

func PointArmAt(pos):
	# turn towards target
	armSprite.rotation = global_position.angle_to_point(pos)
	

func SetAttackLine():
	if attackTarget == null:
		attackLine.visible = false
	else:
		# set attack line
		attackLine.visible = true
		attackLine.set_point_position(1, attackTarget.position - position)
		PointArmAt(attackTarget.position)


func ShowSelectionUI(val = true):
	selectionCircle.visible = val
		
		
func ChangeTargetPosition(where):
	super.ChangeTargetPosition(where)
	PointArmAt(where)
	interactionContainer = null
	

func OnDeath():
	if isDead:
		return
		
	isDead = true
	print("survivor dead!")
	

# simulates breathing in
func _on_oxygen_timer_timeout():
	oxygen += 10 * Spaceship.oxygenLevel / 100.0
	if equipmentSlots[SlotType.Head] >= 0:
		oxygen += inventory[equipmentSlots[SlotType.Head]].data.oxygenGeneration
	
	if oxygen < 0:
		oxygen = 0
	
	if oxygen > 100:
		oxygen = 100
	

func _on_temperature_timer_timeout():
	var diff = (bodyTemperature - 36.5 ) - (Spaceship.temperature - 25)
	
	if diff > 0:
		bodyTemperature -= 0.1
	else:
		bodyTemperature += 0.1
		
		
func _on_nutrition_timer_timeout():
	# consume food
	if Spaceship.ConsumeFood(1):
		nutrition += 30


func AddItemByIndex(type, id):
	inventory.append(Item.new(type, id))
	inventoryWeight += Survivor.ReturnItemData(type, id).weight
	UpdateStats()


func AddItem(item: Item):
	inventory.append(item)
	inventoryWeight += item.data.weight
	UpdateStats()
	
	
func RemoveByIndex(index):
	var item = inventory[index]
	
	# find equipped slot number
	var num = equipmentSlots.find(index)
	if num > -1:
		equipmentSlots[num] = -1
	
	inventory.remove_at(index)
	inventoryWeight -= item.data.weight
	
	# change index of slots that come later in inventory
	for i in len(equipmentSlots):
		if equipmentSlots[i] > index:
			equipmentSlots[i] -= 1
			
	UpdateStats()
	
	return item
		


func _to_string():
	var output: String = "Survivor Info\n"
	output += "HP: " + str(int(health)) + " / " + str(maxHealth) + "\n"
	output += "Speed: " + str(speed * speedModifier) + "\n"
	output += "Defense: " + str(defense * 100) + "%\n"
	output += "Oxygen: " + str(int(oxygen * 100) / 100) + "%\n"
	output += "Body Temperature: " + str(bodyTemperature) + "C\n"
	
	return output
	

func PrintEquipmentStatus():
	var output: String = "Equipment\n"
	if equipmentSlots[SlotType.Primary] >= 0:
		output += "Primary Weapon: " + inventory[equipmentSlots[SlotType.Primary]].data.name + "\n"
	else:
		output += "Primary: None" + "\n"
		
	if equipmentSlots[SlotType.Head] >= 0:
		output += "Head: " + inventory[equipmentSlots[SlotType.Head]].data.name + "\n"
	else:
		output += "Head: None" + "\n"
		
	if equipmentSlots[SlotType.Body] >= 0:
		output += "Body: " + inventory[equipmentSlots[SlotType.Body]].data.name + "\n"
	else:
		output += "Body: None" + "\n"
		
	return output
	

static func ReturnItemDictByType(num):
	if num == 0:
		return itemsDict.Melee
	if num == 1:
		return itemsDict.Ranged
	if num == 2:
		return itemsDict.Head
	if num == 3:
		return itemsDict.Body
	if num == 4:
		return itemsDict.Consumable
		

static func ReturnItemData(type, id):
	return ReturnItemDictByType(type)[id]
	
