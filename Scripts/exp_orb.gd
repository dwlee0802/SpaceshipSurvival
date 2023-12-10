extends Node2D

var fly: bool = false
var target
var FOLLOW_SPEED: float = 10

var expAmount: int = 100

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if fly:
		position += position.direction_to(target.position) * FOLLOW_SPEED
	
		if position.distance_to(target.position) < 5:
			Game.AddExp(expAmount)
			queue_free()

# fly towards pickup location and add exp
func _on_pickup_timer_timeout():
	target = Game.GetClosestSurvivor(position)
	fly = true
