extends "res://Scripts/bullet.gd"


func _on_body_entered(body):
	if penetrationCount < 1:
		queue_free()
		return
		
	if body is Survivor:
		penetrationCount -= 1
		body.ReceiveHit(from, randi_range(5, 15), 0)
		queue_free()
	
	if not body is Enemy:
		queue_free()
