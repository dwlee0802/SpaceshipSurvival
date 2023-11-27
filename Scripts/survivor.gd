extends "res://Scripts/unit.gd"

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine

@onready var selectionCircle = $SelectionCircle

static var weaponsFilePath: String = "res://Data/Weapons.json"
static var weaponsDict

@onready var attackTimer = $AttackTimer
@onready var attackRaycast = $AttackRaycast

@onready var armSprite = $ArmSprite
@onready var muzzleFlashSprite = $ArmSprite/MuzzleFlash

var interactionTarget

var inventory = []
var inventoryWeight: int = 0
var inventoryCapacity: int = 10


# unit stats

# modifies reload time
var reloadSpeed: float = 1

# oxygen level in body. Starts to lose health when it reaches zero
var oxygen: float = 100

# oxygen level in body. Starts to lose health when it reaches zero
var bodyTemperature: float = 36.5

# how well this person can hit targets with a ranged weapon
# added with weapon accuracy to get total accuracy
var accuracy: float = 0.5

# how strong this person is. Affects melee damage and inventory capacity
var strength

# how much damage is reduced when this unit is hit.
var defense: float = 0


# equipment slots

@export var equippedWeaponID: int = 2
var equippedWeapon


func _ready():
	# read in json files
	var file1 = FileAccess.open(weaponsFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	weaponsDict = parse_json(content_as_text1)
	
	attackTimer.timeout.connect(Attack)
	
	EquipWeapon(equippedWeaponID)
	
	$AttackUpdateTimer.timeout.connect(ScanForAttackTargets)


func parse_json(text):
	return JSON.parse_string(text)


func _process(delta):
	oxygen -= delta
	

func _physics_process(delta):
	super._physics_process(delta)
	muzzleFlashSprite.visible = false
	
	if  (not isMoving) and (interactionTarget != null):
		if interactionTarget.Fix(delta):
			interactionTarget = null
		else:
			PointArmAt(interactionTarget.global_position)
	
	if attackTarget != null:
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
	var amount = randi_range(equippedWeapon.DamageMin, equippedWeapon.DamageMax)
	if is_instance_valid(attackTarget):
		attackTarget.ReceiveHit(amount)
	else:
		attackTarget = null
	print("Delt ", str(amount), " damage!")
	muzzleFlashSprite.visible = true


func EquipWeapon(weaponID):
	equippedWeapon = weaponsDict.Weapons[weaponID]
	equippedWeaponID = weaponID
	print(weaponsDict.Weapons[equippedWeaponID].name)
	attackTimer.wait_time = 1 / weaponsDict.Weapons[equippedWeaponID].AttacksPerSecond
	get_node("AttackArea").get_node("CollisionShape2D").shape.set_radius(equippedWeapon.Range)


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


func _on_oxygen_timer_timeout():
	oxygen += 5 * Spaceship.oxygenLevel / 100
	
	if oxygen < 0:
		oxygen = 0
	
	if oxygen == 0:
		print("suffocating!")
