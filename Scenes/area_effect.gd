extends Node2D

var target_position: Vector2


func _init(radius, duration):
	$Area2D/CollisionShape2D.shape.radius = radius
	$EffectSprite.scale = Vector2(radius / 126.0)
	
	
# when duration is over, queue free this
func _on_duration_timer_timeout():
	queue_free()
