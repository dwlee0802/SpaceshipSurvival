extends Area2D

@export var speed: float = 900.0

var weapon

var penetrationCount: int = 1


func _physics_process(delta):
	position += transform.x * speed * delta

func setup(trans: Transform2D):
	transform = trans

func _on_body_entered(body):
	if penetrationCount < 1:
		queue_free()
		return
		
	if body is Enemy:
		penetrationCount -= 1
		body.ReceiveHit(randi_range(weapon.data.minDamage, weapon.data.maxDamage), 0, 1)
		queue_free()
	
	if not body is Survivor:
		queue_free()
