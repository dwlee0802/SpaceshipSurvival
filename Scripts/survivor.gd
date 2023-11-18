extends "res://Scripts/unit.gd"

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine

@export var equippedWeaponID: int = 2
var equippedWeapon

static var weaponsFilePath: String = "res://Data/Weapons.json"
static var weaponsDict

@onready var attackTimer = $AttackTimer

@onready var armSprite = $ArmSprite

@onready var interactionArea = $InteractionArea
var interacting: bool = false

var inventory = []
var inventoryWeight: int = 0
var inventoryCapacity: int = 10

func _ready():
	# read in json files
	var file1 = FileAccess.open(weaponsFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	weaponsDict = parse_json(content_as_text1)
	
	attackTimer.timeout.connect(Attack)
	
	EquipWeapon(equippedWeaponID)

func parse_json(text):
	return JSON.parse_string(text)


func _physics_process(delta):
	super._physics_process(delta)
	
	
	# acquire attack targets
	var targets = attackArea.get_overlapping_bodies()
	
	if len(targets) == 0:
		attackLine.visible = false
		attackTimer.stop()
	else:
		# find closest target
		var minDist = 10000
		for item in targets:
			var dist = position.distance_to(item.position)
			if dist < minDist:
				minDist = dist
				attackTarget = item
		
		# set attack line
		attackLine.visible = true
		attackLine.set_point_position(1, attackTarget.position - position)
		
		if attackTimer.is_stopped():
			attackTimer.start()
	

func Attack():
	# deal damage
	var amount = randi_range(equippedWeapon.DamageMin, equippedWeapon.DamageMax)
	attackTarget.ReceiveHit(amount)
	print("Delt ", str(amount), " damage!")
	

func EquipWeapon(weaponID):
	equippedWeapon = weaponsDict.Weapons[weaponID]
	equippedWeaponID = weaponID
	print(weaponsDict.Weapons[equippedWeaponID].name)
	attackTimer.wait_time = 1 / weaponsDict.Weapons[equippedWeaponID].AttacksPerSecond
	get_node("AttackArea").get_node("CollisionShape2D").shape.set_radius(equippedWeapon.Range)


func _on_interaction_area_body_entered(body):
	if interacting:
		var targets = interactionArea.get_overlapping_bodies()
		print(len(targets))
		for item in targets:
			if item is PlacedItem:
				inventory.append(item.itemID)
				inventoryWeight += weaponsDict.Weapons[item.itemID].Weight
				print("Added ", weaponsDict.Weapons[item.itemID].name, " to inventory.")
				print("New inventory weight: ", inventoryWeight)
				item.queue_free()
				
			if item is Interactable:
				print("interactable")
		
		interacting = false
