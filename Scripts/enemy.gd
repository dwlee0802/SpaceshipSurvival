extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

func _process(delta):
	if attackTarget == null:
		attackTarget = Game.survivors.pick_random()
		target_position = attackTarget.position


func OnDeath():
	print("Dead!")
	queue_free()


func ReceiveHit(amount):
	super.ReceiveHit(amount)
