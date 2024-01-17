extends "res://Scripts/bullet.gd"

func _on_body_entered(body):
	if penetrationCount < 1:
		queue_free()
		return
		
	if body is Survivor:
		penetrationCount -= 1
		var amount = randi_range(from.minDamage, from.maxDamage)
		body.ReceiveHit(from, amount, 0)
		Enemy.AddMutatoinWeights(from.genome, amount)
		queue_free()
	
	if not body is Enemy:
		queue_free()
