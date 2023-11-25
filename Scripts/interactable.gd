extends StaticBody2D

class_name Interactable

# time needed to fix this object
var timeToFix: float = 5

@onready var interactionPoint = $InteractionPoint
@onready var fixTimeLabel = $FixTimeLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timeToFix > 0:
		modulate = Color.RED
		fixTimeLabel.visible = true
		fixTimeLabel.text = str(int(timeToFix))
	else:
		modulate = Color.WHITE
		fixTimeLabel.visible = false
	
	if timeToFix < 0:
		timeToFix = 0
		

func Fix(delta):
	timeToFix -= delta
	if timeToFix > 0:
		return false
	else:
		return true
