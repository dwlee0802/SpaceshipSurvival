extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

var holder: float = 0

func _process(delta):
	if attackTarget == null:
		attackTarget = Game.survivors.pick_random()
		
	target_position = attackTarget.position
	
	if holder > 0:
		bodySprite.modulate = Color.WHITE
		print(holder)
	else:
		bodySprite.modulate = Color.INDIAN_RED
	
	holder -= delta

func OnDeath():
	print("Dead!")
	queue_free()


func ReceiveHit(amount):
	super.ReceiveHit(amount)
	holder = 0.1
