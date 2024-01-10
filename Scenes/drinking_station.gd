extends Interactable
class_name DrinkingStation

var isOperational: bool = true

@onready var drinkSoundPlayer = $DrinkSoundPlayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func Fix(delta):
	if Game.survivor.water + delta * 25 <= 100:
		Game.survivor.water += delta * 25
		if not drinkSoundPlayer.playing:
			drinkSoundPlayer.play()
