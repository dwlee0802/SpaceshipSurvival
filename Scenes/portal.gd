extends Interactable
class_name Portal

var cooldown: float = 30.0

@export var otherPortal: Portal


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timeToFix > 0:
		timeToFix -= delta
		if timeToFix < 0:
			timeToFix = 0
			
	super._process(delta)


func Fix(delta):
	if timeToFix > 0:
		return false
	else:
		timeToFix = cooldown
		return true
