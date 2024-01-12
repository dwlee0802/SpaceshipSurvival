extends Node2D

static var enemyScene = load("res://Scenes/enemy.tscn")

# average amount of spawns per second
static var spawnRate: float = 1

@onready var spawnTimer = $SpawnTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	if spawnTimer.is_stopped():
		spawnTimer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_spawn_timer_timeout():
	if Game.enemies.size() > Game.MAX_ENEMY_COUNT:
		return
		
	if spawnRate > randf():
		# spawn enemy unit
		var newUnit = enemyScene.instantiate()
		newUnit.global_position = global_position
		Game.enemies.append(newUnit)
		Game.gameScene.add_child(newUnit)
		newUnit.reparent(Game.gameScene)
		
		print(name + " spawned an enemy at " + str(newUnit.global_position))
