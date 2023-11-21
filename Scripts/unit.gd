extends CharacterBody2D

class_name Unit

@export var health: int = 1
@export var speed: int = 500

var attackTarget

@onready var nav: NavigationAgent2D = $NavigationAgent2D
@onready var target_position: Vector2 = position

var isMoving: bool = false


func _physics_process(delta):
	if nav.is_navigation_finished():
		isMoving = false
		return
	
	isMoving = true
		
	var dir = Vector2()
	
	dir = nav.get_next_path_position() - global_position
	dir = dir.normalized()
	
	velocity = velocity.lerp(dir * speed, 1)
	
	if nav.is_target_reachable():
		move_and_slide()


func ChangeTargetPosition(pos):
	nav.target_position = pos


func ReceiveHit(amount):
	health -= amount
	
	if health <= 0:
		OnDeath()


func OnDeath():
	print("Dead!")
