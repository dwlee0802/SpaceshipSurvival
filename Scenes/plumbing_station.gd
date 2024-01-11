extends Interactable


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if timeToFix > 0:
		DrinkingStation.plumbingOperational = false
	else:
		DrinkingStation.plumbingOperational = true
