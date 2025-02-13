extends TextureRect
class_name BuffIcon

var data: BuffSkill
@onready var timer: Timer = $BuffDurationTimer

@onready var cooldownIcon = $Cooldown


func _process(_delta):
	cooldownIcon.size = Vector2(size.x, (timer.wait_time - timer.time_left) / timer.wait_time * size.x)
	#cooldownIcon.position = size
	
	
func SetData(skillData: BuffSkill):
	data = skillData
	texture = data.texture
	tooltip_text = data.description
	if data.duration == 0:
		cooldownIcon.visible = false
	

func _on_buff_duration_timer_timeout():
	queue_free()
