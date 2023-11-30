extends "res://Scripts/unit.gd"

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine

@onready var selectionCircle = $SelectionCircle

static var itemsFilePath: String = "res://Data/Items.json"
static var itemsDict

@onready var attackTimer = $AttackTimer
@onready var attackRaycast = $AttackRaycast

@onready var armSprite = $ArmSprite
@onready var muzzleFlashSprite = $ArmSprite/MuzzleFlash

var interactionTarget

# Holds the itemIDs that the player has in its inventory
var inventory = []
var inventoryEquipped = []

# Holds the itemIDs of equipped gear
# 0: Head slot, 1: Body slot, 2: primary weapon slot, 3: secondary weapon slot
# -1 itemID means slot is empty
var equipmentSlots = []

var inventoryWeight: int = 0
var inventoryCapacity: int = 10


# unit stats

# modifies reload time
var reloadSpeed: float = 1

# oxygen level in body. Starts to lose health when it reaches zero
var oxygen: float = 100

var bodyTemperature: float = 36.5

var nutrition: float = 100

# how well this person can hit targets with a ranged weapon
# added with weapon accuracy to get total accuracy
var accuracy: float = 0.5

# how strong this person is. Affects melee damage and inventory capacity
var strength

# how much damage is reduced when this unit is hit.
var defense: float = 0

var sleep: float = 600


var equippedWeapon: Item = null

var isDead: bool = false


# Combat Behavior
var moveAndShoot: bool = true
var fireAtWill: bool = true


func _ready():
	# read in json files
	var file1 = FileAccess.open(itemsFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	itemsDict = parse_json(content_as_text1)
	Item.itemDict = itemsDict
	
	attackTimer.timeout.connect(Attack)
	
	EquipWeapon(Item.new(1, 1))
	
	$AttackUpdateTimer.timeout.connect(ScanForAttackTargets)
	
	# test. add crowbar to inventory
	AddItem(0, 0)
	AddItem(0, 1)
	AddItem(1, 0)
	AddItem(1, 1)
	AddItem(4, 0)


func parse_json(text):
	return JSON.parse_string(text)


func _process(delta):
	if isDead:
		return
		
	oxygen -= delta * 2
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

func _physics_process(delta):
	if isDead:
		return
		
	super._physics_process(delta)
	muzzleFlashSprite.visible = false
	
	if  (not isMoving) and (interactionTarget != null):
		if interactionTarget.Fix(delta):
			interactionTarget = null
		else:
			PointArmAt(interactionTarget.global_position)
	
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
		
		attackRaycast.target_position = attackTarget.position - position

func Attack():
	# deal damage
	var amount = randi_range(equippedWeapon.data.DamageMin, equippedWeapon.data.DamageMax)
	if is_instance_valid(attackTarget):
		attackTarget.ReceiveHit(amount)
	else:
		attackTarget = null
	print("Delt ", str(amount), " damage!")
	muzzleFlashSprite.visible = true


func EquipWeapon(weapon: Item):
	equippedWeapon = weapon
		
	print(equippedWeapon.data.name)
	
	attackTimer.wait_time = 1 / equippedWeapon.data.AttacksPerSecond
	get_node("AttackArea").get_node("CollisionShape2D").shape.set_radius(equippedWeapon.data.Range)


func PointArmAt(position):
	# turn towards target
	armSprite.rotation = global_position.angle_to_point(position)
	

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


func OnDeath():
	if isDead:
		return
		
	isDead = true
	print("survivor dead!")
	

func _on_oxygen_timer_timeout():
	oxygen += 10 * Spaceship.oxygenLevel / 100
	
	if oxygen < 0:
		oxygen = 0
	
	if oxygen > 100:
		oxygen = 100
	

func _on_temperature_timer_timeout():
	var diff = (bodyTemperature - 36.5 ) - (Spaceship.temperature - 25)
	
	if diff > 0:
		bodyTemperature -= 0.5
	else:
		bodyTemperature += 0.5
		
		
func AddItem(type, id):
	inventory.append(Item.new(type, id))


func RemoveItem(type, id):
	var index = inventory.find(Item.new(type, id))
	inventory.remove_at(index)
	return inventory[index]
	
		
class Item:
	var type: int = -1
	var data
	static var itemDict
	
	func _init(_type, _id):
		type = _type
		
		if type == 0:
			data = itemDict.Melee[_id]
		elif type == 1:
			data = itemDict.Range[_id]
		elif type == 2:
			data = itemDict.Head[_id]
		elif type == 3:
			data = itemDict.Body[_id]
		elif type == 4:
			data = itemDict.Consumable[_id]
	
	func _to_string():
		var output = data.name + "\n"
		output += "Type: " + str(type) + "\nID: " + str(data.ID)
		return output
