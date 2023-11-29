extends Module

@onready var moduleArea = $ModuleArea


func _on_heal_timer_timeout():
	if not isOperational:
		return
	for item in moduleArea.get_overlapping_bodies():
		item.ReceiveHit(-randi_range(5, 15))
