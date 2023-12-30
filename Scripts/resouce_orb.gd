extends ExpOrb

var componentAmount: int = 0
var foodAmount: int = 0
var ammoAmount: int = 0

func _ready():
	var rng = randi()
	if rng % 3 == 1:
		componentAmount = randi_range(1, 10)
		$Sprite2D.self_modulate = Color.GOLD
	elif rng % 3 == 2:
		foodAmount = 1
		$Sprite2D.self_modulate = Color.LIME_GREEN
	else:
		ammoAmount = randi_range(10, 30)
		$Sprite2D.self_modulate = Color.DARK_ORANGE
		
	expAmount = 0
	

func _physics_process(_delta):
	if fly:
		position += position.direction_to(target.position) * FOLLOW_SPEED
	
		if position.distance_to(target.position) < 5:
			Spaceship.ConsumeComponents(-componentAmount)
			Spaceship.ConsumeFood(-foodAmount)
			Spaceship.ConsumeAmmo(-ammoAmount)
			queue_free()
	
	
func _on_pickup_area_body_entered(body):
	target = body
	fly = true
