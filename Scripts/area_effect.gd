extends Node2D
class_name AreaEffect

var start_position
var target_position: Vector2
var isPreview: bool = true
var data: Skill
var effectSprite

signal skill_used


func SetData(skill: Skill):
	data = skill
	$Area2D/CollisionShape2D.shape.radius = data.effectRadius
	$EffectSprite.scale = Vector2(data.effectRadius / 128.0, data.effectRadius / 128.0)
	effectSprite = $EffectSprite
	start_position = position
	

func _process(delta):
	if CheckRange():
		effectSprite.self_modulate = Color.GREEN
	else:
		effectSprite.self_modulate = Color.RED
		
	if isPreview:
		effectSprite.self_modulate.a = 0.4
		position = get_global_mouse_position()
		position += get_local_mouse_position()
		

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				isPreview = false
				if CheckRange():
					$DurationTimer.start()
					skill_used.emit(data)
				else:
					queue_free()


func CheckRange():
	if position.distance_to(start_position) <= data.throwRange:
		return true
	else:
		return false
	
	
# when duration is over, queue free this
func _on_duration_timer_timeout():
	queue_free()
