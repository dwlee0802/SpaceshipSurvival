extends "res://Scripts/unit.gd"

@onready var attackArea = $AttackArea
@onready var attackLine = $AttackLine


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
