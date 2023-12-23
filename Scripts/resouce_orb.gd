extends ExpOrb

var componentAmount: int = 0
var foodAmount: int = 0


func _ready():
	if randi() % 2 == 1:
		componentAmount = randi_range(1, 10)
		$Sprite2D.self_modulate = Color.GOLD
	else:
		foodAmount = 1
		$Sprite2D.self_modulate = Color.LIME_GREEN
	
	expAmount = 0
	

func _physics_process(delta):
	if fly:
		position += position.direction_to(target.position) * FOLLOW_SPEED
	
		if position.distance_to(target.position) < 5:
			Spaceship.ConsumeComponents(-componentAmount)
			Spaceship.ConsumeFood(-foodAmount)
			queue_free()
	
	
func _on_pickup_area_body_entered(body):
	target = body
	fly = true
