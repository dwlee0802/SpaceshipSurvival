extends "res://Scripts/bullet.gd"

var minDamage
var maxDamage

var genome


func setup(trans: Transform2D):
	super.setup(trans)


func _on_body_entered(body):
	if penetrationCount < 1:
		queue_free()
		return
		
	if body is Survivor:
		penetrationCount -= 1
		var amount = randi_range(minDamage, maxDamage)
		body.ReceiveHit(from, amount, 0)
		Enemy.AddMutatoinWeights(genome, amount)
		queue_free()
	
	if not body is Enemy:
		queue_free()
