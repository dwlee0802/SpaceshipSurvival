extends TextureRect
class_name BuffIcon

var data: BuffSkill
@onready var timer: Timer = $BuffDurationTimer


func _on_buff_duration_timer_timeout():
	queue_free()
