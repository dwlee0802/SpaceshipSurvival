extends Node2D

class_name Game

static var survivors = []

static var enemies = []

static var time: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	survivors.append($Survivor)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


static func UpdateEnemyTargetPosition():
	for item in enemies:
		if is_instance_valid(item):
			if item.attackTarget != null:
				item.ChangeTargetPosition(item.attackTarget.position)
		else:
			enemies.erase(item)
