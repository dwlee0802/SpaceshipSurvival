extends Node2D

class_name Module

static var enemyScene = preload("res://Scenes/enemy.tscn")

static var errorRate: float = 0.5

@onready var interactablesNode = $Interactables
@onready var spawnPointNode = $SpawnPoints

# each module may spawn an enemy every 1 second. The probability is determined by respawnRate
static var respawnRate: float = 0.5

var isOperational: bool = true

var interactables = []

var spawnPoints = []

var overviewMarker


func _ready():
	for item in interactablesNode.get_children():
		interactables.append(item)
	
	if spawnPointNode != null:
		for item in spawnPointNode.get_children():
			spawnPoints.append(item)
	
	$ErrorTimer.timeout.connect(GenerateErrors)
	$EnemySpawnTimer.timeout.connect(RollEnemySpawn)
	overviewMarker = UserInterfaceManager.MakeMarkerOnSpaceshipOverview()
	overviewMarker.self_modulate = Color.RED
	overviewMarker.position = global_position / 5.80708
	overviewMarker.get_node("Label").text = "!"
	overviewMarker.visible = false


func _process(_delta):
	isOperational = CheckOperational()
	
	# update overview UI if something changed
	if overviewMarker.visible == isOperational:
		overviewMarker.visible = not isOperational
		UserInterfaceManager.UpdateSpaceshipOverviewText()
		
	
func RollEnemySpawn():
	if randf() < respawnRate:
		var newEnemy = enemyScene.instantiate()
		get_parent().get_parent().add_child(newEnemy)
		Game.enemies.append(newEnemy)
		newEnemy.health = 200
		newEnemy.maxHealth = 200
		newEnemy.global_position = spawnPoints.pick_random().global_position


func CheckOperational():
	for item in interactables:
		if item.timeToFix > 0:
			return false
	
	return true


func GenerateErrors():
	for item in interactables:
		if item.timeToFix <= 0:
			if randf() < errorRate:
				item.timeToFix = randi_range(5, 15)
	
