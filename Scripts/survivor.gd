extends "res://Scripts/unit.gd"

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine

var equippedWeapon

static var weaponsFilePath: String = "res://Data/Weapons.json"
static var weaponsDict


func _ready():
	# read in json files
	var file1 = FileAccess.open(weaponsFilePath, FileAccess.READ)

	var content_as_text1 = file1.get_as_text()
	weaponsDict = parse_json(content_as_text1)


func parse_json(text):
	return JSON.parse_string(text)


func _physics_process(delta):
	super._physics_process(delta)
	Attack()


func Attack():
	var targets = attackArea.get_overlapping_bodies()
	
	if len(targets) == 0:
		attackLine.visible = false
		return
	
	# find closest target
	var minDist = 10000
	var closest
	
	for item in targets:
		var dist = position.distance_to(item.position)
		if dist < minDist:
			minDist = dist
			closest = item
	
	attackTarget = closest
	
	# set attack line
	attackLine.visible = true
	attackLine.set_point_position(1, closest.position - position)
	
	# deal damage
	attackTarget.ReceiveHit(100)
