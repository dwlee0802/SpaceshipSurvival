extends Area2D

@export var speed: float = 900.0

var weapon


func _physics_process(delta):
	print(weapon)
	position += transform.x * speed * delta

func setup(trans: Transform2D):
	transform = trans

func _on_body_entered(body):
	if body is Enemy:
		body.ReceiveHit(randi_range(weapon.data.minDamage, weapon.data.maxDamage), 0, 1)
	queue_free()
