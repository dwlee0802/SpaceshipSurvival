extends ExpOrb

var componentAmount: int = 0
var foodAmount: int = 0
var ammoAmount: int = 0

var pickupReady: bool = false

var target_position: Vector2

@onready var pickupArea = $PickupArea
@onready var pickupTimer = $PickupTimer



func _ready():
	expAmount = 0
	target_position = global_position
	SetType()

func SetType(random = true, type = 0):
	var rng = randi()
	if random == false:
		rng = type
		
	if rng % 3 == 1:
		componentAmount = 1
		$Sprite2D.self_modulate = Color.GOLD
	elif rng % 3 == 2:
		foodAmount = 1
		$Sprite2D.self_modulate = Color.LIME_GREEN
	else:
		ammoAmount = randi_range(10, 30)
		$Sprite2D.self_modulate = Color.DARK_ORANGE
	
	
func _physics_process(_delta):
	if pickupReady and fly and is_instance_valid(target):
		global_position += global_position.direction_to(target.global_position) * FOLLOW_SPEED

		if global_position.distance_to(target.global_position) < 5:
			Game.survivor.ChangeComponents(componentAmount)
			Spaceship.ConsumeFood(-foodAmount)
			Spaceship.ConsumeAmmo(-ammoAmount)
			queue_free()
	
	else:
		# wait for pickup if at target position
		if global_position.distance_to(target_position) < 10:
			if pickupReady == false and pickupTimer.is_stopped():
				pickupTimer.start()
		elif pickupReady == false:
			global_position += global_position.direction_to(target_position) * FOLLOW_SPEED
			
		if fly == false:
			var results = pickupArea.get_overlapping_bodies()
			if len(results) > 0:
				fly = true
				target = results[0]
			

func _on_pickup_timer_timeout():
	pickupReady = true
