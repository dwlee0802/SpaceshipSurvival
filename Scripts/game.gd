extends Node2D

class_name Game

static var survivors = []

static var enemies = []

static var time: float = 0

static var damagePopup = preload("res://Scenes/damage_popup.tscn")

static var gameScene

static var spaceship


# Called when the node enters the scene tree for the first time.
func _ready():
	survivors.append($Survivor)
	survivors.append($Survivor2)
	gameScene = self
	spaceship = $Spaceship


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var count = len(survivors)
	for i in count:
		if survivors[i].isDead:
			count -= 1
	
	if count <= 0:
		print("Game Over!")


static func UpdateEnemyTargetPosition():
	for item in enemies:
		if is_instance_valid(item):
			if item.attackTarget != null:
				item.ChangeTargetPosition(item.attackTarget.position)
		else:
			enemies.erase(item)


static func SetSelectionUI(value):
	for item in survivors:
		item.ShowSelectionUI(value)


static func MakeDamagePopup(where, amount, color = Color.DARK_RED):
	var newPopup = damagePopup.instantiate()
	newPopup.position = where
	newPopup.modulate = color
	newPopup.get_node("Label").text = "[center][b]" + str(amount) + "[/b][/center]"
	gameScene.add_child(newPopup)
