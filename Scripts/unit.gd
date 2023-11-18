extends CharacterBody2D

class_name Unit

@export var health: int = 1
@export var speed: int = 300

var attackTarget

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var target_position: Vector2 = position


func _physics_process(delta):
	var dir = Vector2()
	
	nav.target_position = target_position
	
	dir = nav.get_next_path_position() - global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir * speed, 1)
	
	if (target_position - position).length() > 10:
		var collider = move_and_collide(velocity * delta)
	

func ReceiveHit(amount):
	health -= amount
	OnDeath()


func OnDeath():
	print("Dead!")
