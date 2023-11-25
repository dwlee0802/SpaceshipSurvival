extends CharacterBody2D

class_name Unit

@export var health: int = 100
@export var speed: int = 500

var attackTarget

@onready var nav: NavigationAgent2D = $NavigationAgent2D

@onready var target_position: Vector2 = position

@onready var navRaycast = $NavigationRaycasts/RayCast2D
@onready var navRaycast2 = $NavigationRaycasts/RayCast2D2
@onready var navRaycast3 = $NavigationRaycasts/RayCast2D3
@onready var navRaycast4 = $NavigationRaycasts/RayCast2D4
@onready var navRaycast5 = $NavigationRaycasts/RayCast2D5

@onready var navUpdateTimer = $NavigationUpdateTimer

var isMoving: bool = false


func _physics_process(delta):
	if isMoving:
		if CheckDirectPath():
			if position.distance_to(target_position) < 5:
				isMoving = false
				return
				
			print("path clear")
			velocity = position.direction_to(target_position) * speed
			move_and_slide()
		else:
			print("nav")
			
			if nav.is_navigation_finished():
				isMoving = false
				return
				
			var dir = Vector2()
			velocity = position.direction_to(nav.get_next_path_position()) * speed
			move_and_slide()


func ChangeTargetPosition(pos):
	target_position = pos
	isMoving = true
	nav.target_position = target_position


func ReceiveHit(amount):
	health -= amount
	
	if health <= 0:
		OnDeath()


func OnDeath():
	print("Dead!")
	
	
func CheckDirectPath():
	var dir = position.direction_to(target_position)
	var dist = position.distance_to(target_position)
	
	navRaycast.target_position = dir * dist
	navRaycast2.target_position = dir * dist
	navRaycast3.target_position = dir * dist
	navRaycast4.target_position = dir * dist
	navRaycast5.target_position = dir * dist
	
	if navRaycast.get_collider() == null and navRaycast2.get_collider() == null and navRaycast3.get_collider() == null and navRaycast4.get_collider() == null and navRaycast5.get_collider() == null:
		return true
	else:
		return false
