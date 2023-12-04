extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

@onready var navUpdateTimer = $NavUpdateTimer


func _ready():
	STOP_DIST = 60
	
	defense = 0.5
	

func _physics_process(delta):
	if attackTarget == null or attackTarget.isDead:
		attackTarget = Game.survivors.pick_random()
	
	ChangeTargetPosition(attackTarget.position)
	
	if CheckDirectPath(attackTarget.position):
		# update target position realtime
		navUpdateTimer.stop()
	else:
		# if not, pathfinding.
		navUpdateTimer.start()
		
	super._physics_process(delta)


func OnDeath():
	print("Dead!")
	queue_free()


func ReceiveHit(amount, penetration = 0, isRadiationDamage = false):
	super.ReceiveHit(amount, penetration, isRadiationDamage)


func _on_nav_update_timer_timeout():
	ChangeTargetPosition(attackTarget.position)
