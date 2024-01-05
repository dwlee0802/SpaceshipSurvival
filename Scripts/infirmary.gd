extends Module

@onready var moduleArea = $ModuleArea

func _on_heal_timer_timeout():
	if moduleArea != null:
		if not isOperational:
			return
		for item in moduleArea.get_overlapping_bodies():
			var amount = randi_range(5, 15)
			item.HealHealth(amount)
