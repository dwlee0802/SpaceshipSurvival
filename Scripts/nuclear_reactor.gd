extends Module

@onready var radiationArea = $RadiationArea/CollisionShape2D
@onready var radiationSprite = $RadiationArea/Sprite2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if not isOperational:
		radiationArea.shape.radius += delta * 2
	else:
		radiationArea.shape.radius -= delta * 2

	radiationSprite.scale.x = radiationArea.shape.radius / 256 * 2
	radiationSprite.scale.y = radiationArea.shape.radius / 256 * 2
	

func _on_radiation_damage_timer_timeout():
	var results = radiationArea.get_parent().get_overlapping_bodies()
	for item in results:
		item.ReceiveHit(randi_range(5, 15))
