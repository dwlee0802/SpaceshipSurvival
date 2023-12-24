extends "res://Scripts/unit.gd"

class_name Survivor

@export var survivorData: SurvivorData

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
@onready var aimingIndicator = $ArmSprite/AimingIndicator

# the interaction target this unit is moving towards
var interactionTarget

# the interaction object this unit is currently interacting with
var interactionObject

# Holds the itemIDs that the player has in its inventory
# capped at 24 items
var inventory = []
static var MAX_INVENTORY_COUNT = 24

# Holds the index inside inventory of equipped gear
# 0: Head slot, 1: Body slot, 2: primary weapon slot, 3: secondary weapon slot
# -1 itemID means slot is empty
var equipmentSlots = [-1, -1, -1, -1, -1]
var headSlot: Item
var bodySlot: Item
var primarySlot: Item

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

var sleep: float = 100

var isDead: bool = false


# Combat Behavior
var moveAndShoot: bool = true
var fireAtWill: bool = true

# survivors join the player's team by being rescued.
var needsRescue: bool = true

# update unit info ui
# emitted when unit's stats are changed
signal update_unit_ui

# update unit inventory ui
# emitted when unit's inventory is changed
# or when unit is interacting with a placed item or container
signal update_unit_inventory_ui

# update interaction uis
# emitted when unit reaches interaction target
signal update_interaction_ui

# bools to keep track of which ui window is opened for this unit
var isInfoOpen: bool = false
var isInventoryOpen: bool = false
var isInteractionOpen: bool = false

@onready var expBar = $ExpBar/ExpBar
var experiencePoints: int = 0
var level: int = 1
# required exp to level up. Increases 50 percent each level
var requiredEXP: int = 500
@onready var levelUpEffect = $LevelUpEffect/AnimationPlayer

@export var skillSlot_1: Skill
@export var skillSlot_2: Skill


func _ready():
	super._ready()
	# read in json files
	var file1 = FileAccess.open(itemsFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	itemsDict = parse_json(content_as_text1)
	Item.itemDict = itemsDict
	
	attackTimer.timeout.connect(Attack)
	
	inventory.resize(MAX_INVENTORY_COUNT)
	
	$AttackUpdateTimer.timeout.connect(ScanForAttackTargets)
	
	destinationMarker.get_node("Label").text = name
	
	overviewMarker.self_modulate = Color.GREEN
	
	EquipNewItem(Item.new(1,0), SlotType.Primary)
	
	AddItem(Item.new(4,0))
	UpdateStats()
	
	# start with full health
	maxHealth = 200
	health = maxHealth
	

func parse_json(text):
	return JSON.parse_string(text)


func _process(delta):
	if isDead:
		return
	
	ReduceBuffDurations(delta)
	
	oxygen -= delta * 3
	if oxygen < 0:
		oxygen = 0
	if oxygen == 0:
		health -= delta
	if oxygen > 100:
		oxygen = 100
		
	sleep -= delta * 0.25
	if sleep < 0:
		sleep = 0
	if sleep > 100:
		sleep = 100
	
	nutrition -= delta
	if nutrition < 0:
		nutrition = 0
	if nutrition == 0:
		health -= delta
	
	#
	## high fever
	#if bodyTemperature >= 42:
		#health -= delta * 1
	## moderate fever
	#elif bodyTemperature >= 40:
		#health -= delta * 0.5
	## mild fever
	#elif bodyTemperature >= 38:
		#pass
	#
	## Severe Hypothermia
	#if bodyTemperature <= 28:
		#health -= delta * 1
	## moderate Hypothermia
	#elif bodyTemperature <= 32:
		#health -= delta * 0.5
	## mild Hypothermia
	#elif bodyTemperature <= 34:
		#pass
	
	UpdateHealthBar()
	

func _physics_process(delta):
	if isDead:
		return
		
	UpdateStats()
	
	super._physics_process(delta)
	muzzleFlashSprite.visible = false
	
	# destination marker that shows where the unit is headed
	if not isMoving:
		destinationMarker.visible = false
	else:
		destinationMarker.visible = true
		destinationMarker.position = target_position - position
	
	# attack target marker showing what the unit is attacking
	if attackTarget != null and not attackTimer.is_stopped():
		attackTargetMarker.visible = true
		attackTargetMarker.global_position = attackTarget.global_position
	else:
		attackTargetMarker.visible = false
		
	# interactions with interactable objects
	if  (not isMoving) and (interactionTarget != null):
		# unit has reached the interaction Target
		if interactionTarget is Interactable:
			if interactionTarget.Fix(delta):
				# interaction target is operational
				interactionObject = interactionTarget
				interactionTarget = null
				emit_signal("update_unit_inventory_ui")
				emit_signal("update_interaction_ui")
				#isInteractionOpen = true
				#isInventoryOpen = true
			else:
				PointArmAt(interactionTarget.global_position)
		if interactionTarget is PlacedItem:
			# pick up item
			print(interactionTarget)
			AddItem(interactionTarget.item)
			interactionTarget.queue_free()
			interactionTarget = null
			emit_signal("update_unit_inventory_ui")
			
	
	# attack process
	if fireAtWill:
		if attackTarget != null and (moveAndShoot or (not moveAndShoot and not isMoving)):
			attackRaycast.target_position = attackTarget.position - position
			if attackRaycast.get_collider() == null:
				if attackTimer.is_stopped():
					attackTimer.start()
					aimingIndicator.visible = true
				PointArmAt(attackTarget.position)
				aimingIndicator.scale.y = attackTimer.time_left/ attackTimer.wait_time * 1.5
				SetAttackLine()
			else:
				attackTimer.stop()
				aimingIndicator.visible = false
				attackLine.visible = false
		else:
			# line of sight blocked. cant attack
			attackTimer.stop()
			aimingIndicator.visible = false
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
	if isDead:
		return
		
	# deal damage
	# default weapon fists
	var primary
		
	if primarySlot == null:
		primary = Item.new(0,0)
	else:
		primary = primarySlot
		
	if primary.type == ItemType.Melee or (primary.type == ItemType.Ranged and Spaceship.ConsumeAmmo(primary.data.ammoPerShot)):
		var amount = randi_range(primary.data.minDamage, primary.data.maxDamage)
		if is_instance_valid(attackTarget):
			var dir = position.direction_to(attackTarget.position)
			dir *= primary.data.knockBack
			attackTarget.ReceiveHit(amount, primary.data.penetration, endAccuracy, dir, false, self)
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
	if where == SlotType.Head:
		headSlot = item
	if where == SlotType.Body:
		bodySlot = item
	if where == SlotType.Primary:
		primarySlot = item
		
	inventoryWeight += item.data.weight
	
	UpdateStats()


# use the item located at index in inventory
func UseItemAt(index):
	pass


func UpdateStats():
	# equip fists as default
	var primary = Item.new(0,0)
	
	if primarySlot != null:
		primary = primarySlot
		
	var head = headSlot
	var body = bodySlot
	
	defense = 0
	radiationDefense = 0
	if head != null:
		defense += head.data.defense
		radiationDefense += head.data.radiationDefense
	
	if body != null:
		defense += body.data.defense
		radiationDefense += body.data.radiationDefense
	
	inventoryCapacity = strength * 2
	inventoryWeight = 0
	# recalculate inventory weight
	for item: Item in inventory:
		if item != null:
			inventoryWeight += item.data.weight
	
	if headSlot != null:
		inventoryWeight += headSlot.data.weight
	if bodySlot != null:
		inventoryWeight += bodySlot.data.weight
	if primarySlot != null:
		inventoryWeight += primarySlot.data.weight
	
	# modify speed based on inventory weight
	if inventoryWeight > inventoryCapacity:
		speedModifier = 1 - (inventoryWeight - inventoryCapacity) / float(inventoryCapacity)
		if speedModifier < 0:
			speedModifier = 0
	else:
		speedModifier = 1
	
	self.attackSpeedModifier = 1
	self.defenseModifier = 1
	
	for item: BuffObject in self.buffs:
		speedModifier += item.data.speedModifer
		self.attackSpeedModifier += item.data.attackSpeedModifier
		endAccuracy += item.data.accuracyAmount
		defense += item.data.defenseAmount

	if primary != null:
		attackTimer.wait_time = (1 / primary.data.attacksPerSecond + randf_range(-0.01,0.01))/self.attackSpeedModifier
		get_node("AttackArea").get_node("CollisionShape2D").shape.set_radius(primary.data.range)
		endAccuracy = accuracy + primary.data.accuracy
	

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
	interactionObject = null
	isInteractionOpen = false
	emit_signal("update_interaction_ui")
	self.running = false
	

func OnDeath():
	if isDead:
		return
		
	isDead = true
	print("survivor dead!")
	$BodyCollisionShape.set_deferred("disabled", true)
	$ArmSprite.visible = false
	

# simulates breathing in
func _on_oxygen_timer_timeout():
	oxygen += 10 * Spaceship.oxygenLevel / 100.0
	if headSlot != null:
		oxygen += headSlot.data.oxygenGeneration
	
	if oxygen < 0:
		oxygen = 0
	
	if oxygen > 100:
		oxygen = 100
	

func _on_temperature_timer_timeout():
	var diff = Spaceship.temperature - bodyTemperature
	
	bodyTemperature += 0.01 * diff
		
		
func _on_nutrition_timer_timeout():
	# consume food
	if Spaceship.ConsumeFood(1):
		nutrition += 30


func AddItemByIndex(type, id):
	var index = Survivor.GetFirstEmptySlot(inventory)
	inventory[index] = Item.new(type, id)
	inventoryWeight += DataManager.resources[type][id].weight
	UpdateStats()


func AddItem(item: Item):
	var index = Survivor.GetFirstEmptySlot(inventory)
	inventory[index] = item
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
		

func AddExperiencePoints(amount):
	experiencePoints += amount
	if experiencePoints >= requiredEXP:
		level += 1
		requiredEXP  *= 1.5
		experiencePoints = 0
		levelUpEffect.play("level_up_anim")
	
	UpdateExpBar()
	

func UpdateExpBar():
	expBar.size.x = experiencePoints/float(requiredEXP) * healthBarSize


# reduce duration times of buff objects and remove them if they are expired
func ReduceBuffDurations(delta):
	var buffsSize = self.buffs.size()
	for i in range(buffsSize):
		var index = buffsSize - 1 - i
		self.buffs[index].durationLeft -= delta
		if self.buffs[index].durationLeft < 0:
			self.buffs.remove_at(index)
		
		
	
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


static func GetFirstEmptySlot(list):
	for i in len(list):
		if list[i] == null:
			return i
	
	return -1
	
	
func PrintHealthStats() -> String:
	var output = "Health Stats:\n"
	output += "HP: " + str(int(health * 100) / 100.0) + "/" + str(maxHealth) + "\n"
	output += "Temp: " + str(int(bodyTemperature * 10000) / 10000.0) + "C\n"
	output += "Oxygen: " + str(int(oxygen * 100) / 100) + "%\n"
	output += "Nutrition: " + str(int(nutrition * 100) / 100) + "%\n"
	output += "Sleep: " + str(int(sleep * 100)/100) + "%\n"
	
	return output


func PrintCombatStats() -> String:
	var output = "Combat Stats:\n"
	output += "Speed: " + str(speed * (speedModifier + int(self.running))) + "\n"
	output += "Strength: " + str(strength) + "\n"
	output += "Accuracy: " + str(int(endAccuracy * 100) / 100) + "%\n"
	output += "Evasion" + str(int(evasion * 100) / 100) + "%\n"
	output += "Defense: " + str(int(defense * 100)) + "%\n"
	output += "Rad. Defense: " + str(int(radiationDefense * 100) / 100) + "%\n"
	
	return output
	
	
func PrintMiscStats() -> String:
	var output = "Name Here\n"
	output += "Character job here\n"
	output += "LV: " + str(level) + "\n"
	output += str(experiencePoints) + "/" + str(requiredEXP) + "\n"
	return output
