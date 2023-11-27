extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

@onready var navUpdateTimer = $NavUpdateTimer

var holder: float = 0


func _ready():
	STOP_DIST = 60

func _physics_process(delta):
	if attackTarget == null or not is_instance_valid(attackTarget) or attackTarget.isDead:
		attackTarget = Game.survivors.pick_random()
	
	ChangeTargetPosition(attackTarget.position)
	
	if CheckDirectPath(attackTarget.position):
		# update target position realtime
		navUpdateTimer.stop()
	else:
		# if not, pathfinding.
		navUpdateTimer.start()
		
	super._physics_process(delta)
	
	if holder > 0:
		bodySprite.modulate = Color.WHITE
	else:
		bodySprite.modulate = Color.INDIAN_RED
	
	holder -= delta


func OnDeath():
	print("Dead!")
	queue_free()


func ReceiveHit(amount):
	super.ReceiveHit(amount)
	holder = 0.1


func _on_nav_update_timer_timeout():
	ChangeTargetPosition(attackTarget.position)
