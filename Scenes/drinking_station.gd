extends Interactable
class_name DrinkingStation

var isOperational: bool = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func Fix(delta):
	if Game.survivor.water + delta * 25 <= 100:
		Game.survivor.water += delta * 25
