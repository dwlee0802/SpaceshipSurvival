extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

var holder: float = 0


func _physics_process(delta):
	if attackTarget == null:
		attackTarget = Game.survivors.pick_random()
	
	if attackTarget.isMoving:
		ChangeTargetPosition(attackTarget.position)
		
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
