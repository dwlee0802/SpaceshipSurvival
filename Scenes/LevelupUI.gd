extends "res://Scripts/draggable_window.gd"

@onready var optionButton_1 = $Option1
@onready var optionButton_2 = $Option2
@onready var optionButton_3 = $Option3

# holds the upgrade options
# assume size is 3
var options = []

var connected: bool = false


func _process(delta):
	super._process(delta)
	
	if connected == false:
		Game.survivor.level_up.connect(on_level_up)
		connected = true
		

func on_level_up():
	# show this window
	visible = true
	# stop time
	#Engine.time_scale = 0
	# generate upgrade options
	# update ui
	pass
	
	
func SetOptions(newOptions):
	options = newOptions
	
	# update UI
	optionButton_1.get_node("Label").text = newOptions[0].name
	optionButton_2.get_node("Label").text = newOptions[1].name
	optionButton_3.get_node("Label").text = newOptions[2].name
	
	
func _upgrade_option_selected(num):
	pass


func _on_pass_button_pressed():
	pass # Replace with function body.
