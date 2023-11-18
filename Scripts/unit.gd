extends CharacterBody2D

class_name Unit

var health: int = 1

@export var speed: int = 100
var acc: float = 1

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var target_position: Vector2 = position


func _physics_process(delta):
	var dir = Vector2()
	
	nav.target_position = get_global_mouse_position()
	
	dir = nav.get_next_path_position() - global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir * speed, acc)
	
	var collider = move_and_collide(velocity * delta)
	

func ReceiveHit(amount):
	health -= amount
	OnDeath()


func OnDeath():
	print("Dead!")
