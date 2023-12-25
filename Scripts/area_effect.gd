extends Node2D
class_name AreaEffect

var start_position: Vector2
var target_position: Vector2
var data: Skill

var isPreview: bool = true

@onready var effectSprite = $EffectSprite

signal skill_used


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if CheckRange():
					isPreview = false
					$DurationTimer.start()
					skill_used.emit(data)
				else:
					queue_free()
		
			InputManager.waitingForSkillLocation = false


func SetData(skill: Skill):
	data = skill
	start_position = Vector2.ZERO
	$Area2D/CollisionShape2D.shape.radius = data.effectRadius
	effectSprite.scale = Vector2(data.effectRadius / 128.0, data.effectRadius / 128.0)
	

func _physics_process(delta):
	if isPreview:
		position = get_global_mouse_position()
		position += get_local_mouse_position()
		
	if CheckRange():
		effectSprite.self_modulate = Color.GREEN
	else:
		effectSprite.self_modulate = Color.RED
	effectSprite.self_modulate.a = 0.4
		
		
# when duration is over, queue free this
func _on_duration_timer_timeout():
	queue_free()


func CheckRange():
	if start_position.distance_to(position) <= data.throwRange:
		return true
	else:
		return false
