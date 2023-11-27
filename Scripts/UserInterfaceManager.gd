extends Node

class_name UserInterfaceManager

static var travelProgressUI


# Called when the node enters the scene tree for the first time.
func _ready():
	travelProgressUI = $TravelProgressUI


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# change scale x of progress bar based on progress
static func UpdateTravelProgressUI(cur, max):
	var maxSize = travelProgressUI.get_node("Background").size.x
	
	travelProgressUI.get_node("ProgressBar").size.x = maxSize * cur / max
	travelProgressUI.get_node("SpaceshipIcon").position.x = maxSize * cur / max - 2
	
	travelProgressUI.get_node("SpaceshipIcon/ProgressPercentLabel").text = str(int(float(cur)/max * 100)) + "%"
