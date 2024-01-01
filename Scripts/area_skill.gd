extends Node2D
class_name AreaEffect

var start_position
var target_position: Vector2
var isPreview: bool = true
var data: Skill
var effectSprite
var durationTimer: Timer

@onready var effectArea = $Area2D

signal skill_used

var projectileObject
var projectileSpeed: int = 500

@onready var allowAttackTimer = $AttackAllowTimer


func SetData(skill: Skill):
	data = skill
	$Area2D/CollisionShape2D.shape.radius = data.effectRadius
	$EffectSprite.scale = Vector2(data.effectRadius / 128.0, data.effectRadius / 128.0)
	effectSprite = $EffectSprite
	start_position = position
	durationTimer = $DurationTimer
	projectileObject = Game.MakeProjectile()
	add_sibling(projectileObject)


func _process(delta):
	if CheckRange() and CheckLineOfSight(get_parent().position, global_position):
		effectSprite.self_modulate = Color.GREEN
	else:
		effectSprite.self_modulate = Color.RED
		
	if isPreview:
		effectSprite.self_modulate.a = 0.4
		position = get_global_mouse_position()
		position += get_local_mouse_position()
		projectileObject.visible = false
	else:
		projectileObject.visible = true
		projectileObject.global_position += projectileObject.position.direction_to(target_position) * projectileSpeed * delta

		if projectileObject.position.distance_squared_to(target_position) < 20:
			projectileObject.queue_free()
			# it is a one time effect skill
			if data.duration == 0:
				Effect()
				var callable = Callable(Game, "MakeExplosionEffect")
				var eff = callable.call(global_position)
				eff.get_node("Sprite2D").scale = effectSprite.scale
				Camera.ShakeScreen(20,8)
				queue_free()
			# it lasts for a while on the map
			else:
				durationTimer.start()
		
		if allowAttackTimer.is_stopped():
			allowAttackTimer.start()


func _input(event):
	if effectSprite.visible == false:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				isPreview = false
				if CheckRange() and CheckLineOfSight(get_parent().position, global_position):
					target_position = global_position
					skill_used.emit(data)
					projectileObject.position = get_parent().position
				else:
					queue_free()
				effectSprite.visible = false
			


func CheckRange():
	if position.distance_to(start_position) <= data.throwRange:
		return true
	else:
		return false
	
	
# when duration is over, queue free this
func _on_duration_timer_timeout():
	queue_free()


func Effect():
	var results = effectArea.get_overlapping_bodies()
	for item in results:
		if not CheckLineOfSight(global_position, item.global_position):
			continue
			
		var dir = global_position.direction_to(item.position)
		if item is Survivor:
			dir = Vector2.ZERO
		item.ReceiveHit(self, randi_range(data.damageMin, data.damageMax), 0)
	
	
func CheckLineOfSight(start, end, mask = 16):
	var space = get_viewport().world_2d.direct_space_state
	var param = PhysicsRayQueryParameters2D.create(start, end, mask)
	var result = space.intersect_ray(param)
	if result.is_empty():
		return true
	else:
		return false


func _exit_tree():
	Game.survivor.usingSkill = false


func _on_attack_allow_timer_timeout():
	Game.survivor.usingSkill = false
