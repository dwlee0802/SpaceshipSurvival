extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

@onready var navUpdateTimer = $NavUpdateTimer

@onready var hitParticleEffect = $HitParticleEffect

var placedItemScene = preload("res://Scenes/placed_item.tscn")

static var expOrb = preload("res://Scenes/exp_orb.tscn")


func _ready():
	super._ready()
	
	STOP_DIST = 60
	
	defense = 0.5
	
	evasion = 0.1
	
	overviewMarker.self_modulate = Color.DARK_ORANGE
	

# movement
# if there is a direct path to target, update target position in realtime
# else, update it every second
func _physics_process(delta):
	if attackTarget == null or attackTarget.isDead:
		attackTarget = Game.survivors.pick_random()
	
	ChangeTargetPosition(attackTarget.position)
	
	if CheckDirectPath(attackTarget.position):
		if position.distance_to(target_position) < STOP_DIST:
			isMoving = false
			return
		# update target position realtime
		navUpdateTimer.stop()
		velocity = position.direction_to(target_position) * speed * speedModifier + knockBack
	else:
		# if not, pathfinding.
		if navUpdateTimer.is_stopped():
			navUpdateTimer.start()
		
	move_and_slide()
	
	overviewMarker.position = position / 5.80708
	overviewMarker.visible = true
	
	# knock back damping
	if knockBack.length() > 0:
		knockBack = knockBack.normalized() * (knockBack.length() - delta * 1000)
	else:
		knockBack = Vector2.ZERO


func OnDeath():
	super.OnDeath()
	print("Dead!")
	Game.MakeEnemyDeathEffect(global_position)
	# roll random drop
	if randf() < 0.5:
		DropItem()
		
	queue_free()


func ReceiveHit(amount, penetration: float = 0, _accuracy: float = 0, knockBackVec: Vector2 = Vector2.ZERO, isRadiationDamage = false, from = null):
	if super.ReceiveHit(amount, penetration, _accuracy, knockBackVec, isRadiationDamage):
		hitParticleEffect.emitting = true
		hitParticleEffect.rotation = Vector2.RIGHT.angle_to(knockBackVec)
		animationPlayer.play("hit_animation")
		
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
	ChangeTargetPosition(attackTarget.position)
	velocity = position.direction_to(nav.get_next_path_position()) * speed * speedModifier + knockBack

	
func MakeExpOrb(target):
	var newOrb = expOrb.instantiate()
	Game.gameScene.add_child(newOrb)
	newOrb.position = global_position
	newOrb.target = target
