extends Node2D
class_name ExpOrb

var fly: bool = false
var target
var FOLLOW_SPEED: float = 10

var expAmount: int = 50

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if target == null:
		queue_free()
		
	if fly:
		position += position.direction_to(target.position) * FOLLOW_SPEED
	
		if position.distance_to(target.position) < 5:
			Game.GainExperiencePoints(target, expAmount)
			queue_free()


# fly towards pickup location and add exp
func _on_pickup_timer_timeout():
	fly = true
