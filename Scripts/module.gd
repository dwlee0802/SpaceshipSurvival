extends Node2D

class_name Module

static var enemyScene = preload("res://Scenes/enemy.tscn")

static var errorRate: float = 0.1

@onready var interactablesNode = $Interactables

# each module may spawn an enemy every 1 second. The probability is determined by respawnRate
static var respawnRate: float = 0.5

var isOperational: bool = true

var interactables = []

var spawnPoints = []


func _ready():
	for item in interactablesNode.get_children():
		interactables.append(item)
	
	$ErrorTimer.timeout.connect(GenerateErrors)
	$EnemySpawnTimer.timeout.connect(RollEnemySpawn)


func RollEnemySpawn():
	if randf() < respawnRate:
		var newEnemy = enemyScene.instantiate()
		get_parent().get_parent().add_child(newEnemy)
		Game.enemies.append(newEnemy)
		newEnemy.health = 200
		newEnemy.global_position = position + Vector2(randf_range(-100, 100), randf_range(-100, 100))


func CheckOperational():
	for item in interactables:
		if item.timeToFix > 0:
			return false
	
	return true


func GenerateErrors():
	for item in interactables:
		if item.timeToFix <= 0:
			if randf() < errorRate:
				item.timeToFix = randi_range(5, 20)
