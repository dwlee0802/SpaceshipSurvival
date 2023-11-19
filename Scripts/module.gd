extends Node2D

class_name Module

static var enemyScene = preload("res://Scenes/enemy.tscn")

# each module may spawn an enemy every 1 second. The probability is determined by respawnRate
static var respawnRate: float = 0.2

var isOperational: bool = true


func RollEnemySpawn():
	if randf() < respawnRate:
		var newEnemy = enemyScene.instantiate()
		add_child(newEnemy)
		newEnemy.position = position + Vector2(randf_range(-100, 100), randf_range(-100, 100))
