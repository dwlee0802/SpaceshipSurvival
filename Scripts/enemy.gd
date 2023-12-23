extends "res://Scripts/unit.gd"
class_name Enemy

@onready var bodySprite = $BodySprite

@onready var navUpdateTimer = $NavUpdateTimer

@onready var hitParticleEffect = $HitParticleEffect

var placedItemScene = preload("res://Scenes/placed_item.tscn")

static var expOrb = preload("res://Scenes/exp_orb.tscn")

var itemDropProbability: float = 0.1
var componentDropProbability: float = 0.1

@onready var alertArea = $AlertArea
@onready var detectionArea = $DetectionArea
@onready var attackArea = $AttackArea
@onready var attackTimer = $AttackTimer

@onready var roamTimer = $RoamTimer

func _ready():
	super._ready()
	
	STOP_DIST = 60
	
	defense = 0.5
	
	evasion = 0.1
	
	overviewMarker.self_modulate = Color.DARK_ORANGE
	
	target_position = global_position
	

# movement
# if there is a direct path to target, update target position in realtime
# else, update it every second
func _physics_process(delta):
	overviewMarker.position = position / 5.80708
	overviewMarker.visible = true
	
	# knock back damping
	if knockBack.length() > 0:
		knockBack = knockBack.normalized() * (knockBack.length() - delta * 1000)
	else:
		knockBack = Vector2.ZERO
		
	# update nav target position every 0.5 seconds if it is close
	# otherwise update every 10 seconds or so
	if attackTarget != null:
		target_position = attackTarget.position	
		
		if position.distance_to(attackTarget.position) > 10000:
			navUpdateTimer.wait_time = randf_range(5,10)
		else:
			navUpdateTimer.wait_time = 0.5
			
		var results = attackArea.get_overlapping_bodies()
		if len(results) > 0:
			if attackTimer.is_stopped():
				attackTimer.start()
			return
	
	if not isMoving:
		if roamTimer.is_stopped():
			roamTimer.start()
		
	if isMoving:
		if position.distance_to(target_position) < STOP_DIST:
			isMoving = false
			return
				
		# direct path exists to target
		if CheckDirectPath(target_position):
			# update target position realtime
			navUpdateTimer.stop()
			velocity = position.direction_to(target_position) * speed * speedModifier + knockBack
		else:
			# if not, pathfinding.
			ChangeTargetPosition(target_position)
			if navUpdateTimer.is_stopped():
				navUpdateTimer.start()
			
		move_and_slide()
	

func OnDeath():
	super.OnDeath()
	print("Dead!")
	Game.MakeEnemyDeathEffect(global_position)
	# roll random drop
	if randf() < itemDropProbability:
		DropItem()
		
	queue_free()


func ReceiveHit(amount, penetration: float = 0, _accuracy: float = 0, knockBackVec: Vector2 = Vector2.ZERO, isRadiationDamage = false, from = null):
	# if attack target is null, move towards attacker
	if attackTarget == null and from is Survivor:
		attackTarget = from
		ChangeTargetPosition(attackTarget.position)
		
	if super.ReceiveHit(amount, penetration, _accuracy, knockBackVec, isRadiationDamage):
		hitParticleEffect.emitting = true
		hitParticleEffect.rotation = Vector2.RIGHT.angle_to(knockBackVec)
		
	if health <= 0:
		OnDeath()
		if not isRadiationDamage:
			MakeExpOrb(from)


func DropItem():
	var newItem = placedItemScene.instantiate()
	get_parent().add_child(newItem)
	newItem.item = Item.new(4,0)
	newItem.position = global_position
	print("spawned item")
	

func _on_nav_update_timer_timeout():
	velocity = position.direction_to(nav.get_next_path_position()) * speed * speedModifier + knockBack

	
func MakeExpOrb(target):
	var newOrb = expOrb.instantiate()
	Game.gameScene.add_child(newOrb)
	newOrb.position = global_position
	newOrb.target = target


# set attack target to closest survivor within detection range
func _on_detection_update_timer_timeout():
	var results = detectionArea.get_overlapping_bodies()
	var smallestDist = 100000
	var output = null
	for unit in results:
		if CheckLineOfSight(position, unit.position):
			var dist = unit.position.distance_to(position)
			if dist < smallestDist:
				smallestDist = dist
				output = unit
	
	ChangeAttackTarget(output)


func CheckLineOfSight(start, end, mask = 16):
	var space = get_viewport().world_2d.direct_space_state
	var param = PhysicsRayQueryParameters2D.create(start, end, mask)
	var result = space.intersect_ray(param)
	
	if result.is_empty():
		return true
	else:
		return false


func ChangeAttackTarget(unit):
	attackTarget = unit
	AlertOthers(unit)
	Game.UpdateEnemyTargetPosition()
	

# alerts its friends nearby
func AlertOthers(survivor: Survivor):
	var results = alertArea.get_overlapping_bodies()
	for item : Enemy in results:
		if item.attackTarget == null:
			item.attackTarget = survivor


func _on_detection_area_body_exited(body):
	_on_detection_update_timer_timeout()


# pick new location after stopping for a bit
func _on_roam_timer_timeout():
	var randomPos = position
	
	while true:
		var angle = randf_range(0, 360)
		randomPos = position + Vector2.from_angle(angle) * randi_range(100, 300)
		
		if CheckLineOfSight(position, randomPos):
			break
			
	ChangeTargetPosition(randomPos)
	

func _on_attack_timer_timeout():
	var results = attackArea.get_overlapping_bodies()
	if len(results) > 0:
		var target : Survivor = results[0]
		target.ReceiveHit(10,0,100)
