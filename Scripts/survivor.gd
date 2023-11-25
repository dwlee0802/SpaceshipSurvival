extends "res://Scripts/unit.gd"

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine

@export var equippedWeaponID: int = 2
var equippedWeapon

static var weaponsFilePath: String = "res://Data/Weapons.json"
static var weaponsDict

@onready var attackTimer = $AttackTimer

@onready var armSprite = $ArmSprite
@onready var muzzleFlashSprite = $ArmSprite/MuzzleFlash

var interactionTarget

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
	
	$AttackUpdateTimer.timeout.connect(ScanForAttackTargets)


func parse_json(text):
	return JSON.parse_string(text)


func _physics_process(delta):
	super._physics_process(delta)
	muzzleFlashSprite.visible = false
	
	if attackTarget != null:
		PointArmAt(attackTarget.position)
	
	SetAttackLine()
	
	if not isMoving and interactionTarget != null:
		if interactionTarget.Fix(delta):
			interactionTarget = null
		else:
			PointArmAt(interactionTarget.global_position)
	
	
func ScanForAttackTargets():
	# acquire attack targets
	var targets = attackArea.get_overlapping_bodies()
	attackTarget = null
	
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
		
		
		if attackTimer.is_stopped():
			attackTimer.start()


func Attack():
	# deal damage
	var amount = randi_range(equippedWeapon.DamageMin, equippedWeapon.DamageMax)
	attackTarget.ReceiveHit(amount)
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
		
		
func ChangeTargetPosition(where):
	super.ChangeTargetPosition(where)
	PointArmAt(where)
