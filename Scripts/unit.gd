extends CharacterBody2D

class_name Unit

@export var health: float = 50
@export var maxHealth: int = 100
@export var speed: int = 100
var speedModifier: float = 1
# how much damage is reduced when this unit is hit.
@export var defense: float = 0
@export var radiationDefense: float = 0
@export var evasion: float = 0
# how well this person can hit targets with a ranged weapon
# added with weapon accuracy to get total accuracy
@export var accuracy: float = 0

var attackTarget

@onready var nav: NavigationAgent2D = $NavigationAgent2D

@onready var target_position: Vector2 = position

var knockBack: Vector2 = Vector2.ZERO

@onready var navRaycast = $NavigationRaycasts/RayCast2D
@onready var navRaycast2 = $NavigationRaycasts/RayCast2D2
@onready var navRaycast3 = $NavigationRaycasts/RayCast2D3
@onready var navRaycast4 = $NavigationRaycasts/RayCast2D4
@onready var navRaycast5 = $NavigationRaycasts/RayCast2D5

@onready var healthBar = $HealthBar/HealthBar

var isMoving: bool = false

var STOP_DIST = 5

var radiationDamageTimeHolder = 2

var overviewMarker

@onready var animationPlayer = $AnimationPlayer

static var healthBarSize = 50


func _ready():
	overviewMarker = UserInterfaceManager.MakeMarkerOnSpaceshipOverview()
	

func _physics_process(delta):
	# update marker on spaceship overview UI
	overviewMarker.position = position / 5.80708
	overviewMarker.visible = true
	
	if health <= 0:
		OnDeath()
	
	if isMoving:
		# dont use nav is there is a direct path to target
		if CheckDirectPath():
			if position.distance_to(target_position) < STOP_DIST:
				isMoving = false
				return
				
			velocity = position.direction_to(target_position) * speed * speedModifier + knockBack
			move_and_slide()
		# use nav if there's an obstacle to go around
		else:
			if nav.is_navigation_finished():
				isMoving = false
				return
			
			velocity = position.direction_to(nav.get_next_path_position()) * speed * speedModifier + knockBack
			move_and_slide()
	
	# knock back damping
	if knockBack.length() > 0:
		knockBack = knockBack.normalized() * (knockBack.length() - delta * 10)
	else:
		knockBack = Vector2.ZERO
		

func ChangeTargetPosition(pos):
	target_position = pos
	isMoving = true
	nav.target_position = target_position


func UpdateHealthBar():
	healthBar.size.x = health/maxHealth * healthBarSize


func ReceiveHit(amount, pene: float = 0, acc: float = 0, knockBackVector: Vector2 = Vector2.ZERO, isRadiationDamage = false, from = null):
	# accuracy check
	var endAccuracy = acc - evasion
	if endAccuracy < 0:
		endAccuracy = 0
	
	var rng = randf()
	if rng > endAccuracy:
		print(endAccuracy)
		print(rng)
		Game.MakeDamagePopup(position, 0)
		return false
		
	print("Init: ", amount)
	var endDefense
	if not isRadiationDamage:
		endDefense = defense - pene
		if endDefense < 0:
			endDefense = 0
	else:
		endDefense = radiationDefense
		
	print("Eff. Defense: ", endDefense)
	amount = int(amount * (1 - endDefense))
	
	print("Eff. Damage: ", amount)
	health -= amount
	
	print("Left HP: " + str(health))
	Game.MakeDamagePopup(position, amount)
	
	UpdateHealthBar()
	
	# apply knockback
	knockBack += knockBackVector
	
	return true


func HealHealth(amount):
	health += amount
	if health > maxHealth:
		health = maxHealth
	
	Game.MakeDamagePopup(position, amount, Color.LIME_GREEN)
	UpdateHealthBar()
	

func OnDeath():
	print("Dead!")
	overviewMarker.queue_free()
	
	
func CheckDirectPath(pos = target_position, start = position):
	var dir = start.direction_to(pos)
	var dist = start.distance_to(pos)
	
	navRaycast.target_position = dir * dist
	navRaycast2.target_position = dir * dist
	navRaycast3.target_position = dir * dist
	navRaycast4.target_position = dir * dist
	navRaycast5.target_position = dir * dist
	
	if navRaycast.get_collider() == null and navRaycast2.get_collider() == null and navRaycast3.get_collider() == null and navRaycast4.get_collider() == null and navRaycast5.get_collider() == null:
		return true
	else:
		return false
