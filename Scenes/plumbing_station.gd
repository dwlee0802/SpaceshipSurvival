extends Interactable
class_name PlumbingRoom


# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if timeToFix > 0:
		DrinkingStation.plumbingOperational = false
	else:
		DrinkingStation.plumbingOperational = true
