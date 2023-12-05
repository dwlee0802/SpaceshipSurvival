extends "res://Scripts/unit.gd"

@onready var bodySprite = $BodySprite

@onready var navUpdateTimer = $NavUpdateTimer

@onready var hitParticleEffect = $HitParticleEffect


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
	if health <= 0:
		OnDeath()
		
	if attackTarget == null or attackTarget.isDead:
		attackTarget = Game.survivors.pick_random()
	
	ChangeTargetPosition(attackTarget.position)
	
	if CheckDirectPath(attackTarget.position):
		if position.distance_to(target_position) < STOP_DIST:
			isMoving = false
			return
		# update target position realtime
		navUpdateTimer.stop()
		velocity = position.direction_to(target_position) * speed * speedModifier
	else:
		# if not, pathfinding.
		if navUpdateTimer.is_stopped():
			navUpdateTimer.start()
		
	move_and_slide()
	
	overviewMarker.position = position / 5.80708
	overviewMarker.visible = true
	


func OnDeath():
	super.OnDeath()
	print("Dead!")
	Game.MakeEnemyDeathEffect(global_position)
	queue_free()


func ReceiveHit(amount, penetration: float = 0, accuracy: float = 0, isRadiationDamage = false):
	if super.ReceiveHit(amount, penetration, accuracy, isRadiationDamage):
		hitParticleEffect.emitting = true
		animationPlayer.play("hit_animation")


func _on_nav_update_timer_timeout():
	ChangeTargetPosition(attackTarget.position)
	velocity = position.direction_to(nav.get_next_path_position()) * speed * speedModifier
