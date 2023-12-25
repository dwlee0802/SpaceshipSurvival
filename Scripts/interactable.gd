extends StaticBody2D

class_name Interactable

# time needed to fix this object
var timeToFix: float = 0

@onready var interactionPoint = $InteractionPoint
var fixTimeLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	fixTimeLabel = get_node_or_null("FixTimeLabel")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if fixTimeLabel == null:
		return
		
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
