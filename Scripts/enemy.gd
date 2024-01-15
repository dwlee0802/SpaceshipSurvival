extends "res://Scripts/unit.gd"
class_name Enemy

@onready var bodySprite = $BodySprite

@onready var navUpdateTimer = $NavUpdateTimer

@onready var hitParticleEffect = $HitParticleEffect

var placedItemScene = preload("res://Scenes/placed_item.tscn")

static var expOrb = preload("res://Scenes/exp_orb.tscn")
static var resourceOrb = preload("res://Scenes/resouce_orb.tscn")

var itemDropProbability: float = 0.01
var resourceDropProbability: float = 0.5

@onready var alertArea = $AlertArea
@onready var detectionArea = $DetectionArea
@onready var attackArea = $AttackArea
@onready var attackTimer = $AttackTimer

@onready var roamTimer = $RoamTimer

@onready var audioPlayer = $AudioStreamPlayer2D
@onready var hitSoundPlayer = $HitSoundEffectPlayer

var rangedAttack: bool = false
static var bulletScene = load("res://Scenes/enemy_bullet.tscn")

# Enemy Mutation System
# the standard distribution of mutation points of all enemies
# it is updated when enemies deal damage to survivor
# amount of damage dealt is added to weights array
# next mutation of the base Genome is weighted random
var mutationChoice: GeneName
static var baseGenome = []
static var nextMutationChoiceWeights = []
enum GeneName {HP, Speed, Defense, Damage, Penetration, RadiationDefense, AttackRange, Explosive}


func _ready():
	super._ready()
	
	STOP_DIST = 60
	
	defense = 0.5
	
	evasion = 0.1
	
	overviewMarker.self_modulate = Color.DARK_ORANGE
	
	target_position = global_position


func SetAttackRange(amount):
	attackArea.get_node("CollisionShape2D").shape.set_radius(amount)
	
	
# movement
# if there is a direct path to target, update target position in realtime
# else, update it every second
func _physics_process(delta):
	overviewMarker.position = position / 5.80708
	overviewMarker.visible = true
	
	# knock back damping
	if knockBack.length() > 0:
		knockBack = knockBack.normalized() * (knockBack.length() - delta * 800)
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
		# move sound disabled due to lag
		#if audioPlayer.playing:
			#audioPlayer.stop()
		
	if true:
		if isMoving and position.distance_to(target_position) < STOP_DIST:
			velocity = Vector2.ZERO
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
		call_deferred("DropItem")
	if randf() < resourceDropProbability:
		call_deferred("DropResource")
		
	queue_free()


func ReceiveHit(from, amount, penetration = 0, isRadiationDamage = false, knockBackAmount = 0):
	# if attack target is null, move towards attacker
	if attackTarget == null and from is Survivor or from is AreaEffect:
		attackTarget = Game.survivor
		ChangeTargetPosition(attackTarget.position)
		
	if super.ReceiveHit(from, amount, penetration, isRadiationDamage, knockBackAmount):
		var temp = Game.MakeEnemyHitEffect(global_position, from.global_position.direction_to(global_position).angle())
		temp.emitting = true
		
	if health <= 0:
		OnDeath()
		if not isRadiationDamage:
			if from is Survivor:
				MakeExpOrb(from)
			elif from is AreaEffect:
				MakeExpOrb(from.get_parent())
				
	hitSoundPlayer.play()
	

func DropItem():
	var newItem = placedItemScene.instantiate()
	get_parent().add_child(newItem)
	newItem.item = Item.new(4,0)
	newItem.position = global_position
	print("spawned item")


func DropResource():
	var newOrb = resourceOrb.instantiate()
	get_tree().root.add_child(newOrb)
	newOrb.position = global_position + Vector2(randi_range(-20, 20), randi_range(-20, 20))
	newOrb.target_position = newOrb.position
	newOrb.SetType()
	

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


func RangedAttack(to_pos):
	var newBullet = bulletScene.instantiate()
	Game.gameScene.add_child(newBullet)
	newBullet.from = self
	newBullet.position = global_position
	newBullet.rotation = global_position.angle_to_point(to_pos)
	
	
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
		if rangedAttack:
			if CheckLineOfSight(global_position, results[0].position):
				RangedAttack(results[0].global_position)
		else:
			var target : Survivor = results[0]
			target.ReceiveHit(self, randi_range(5,15), 0)
