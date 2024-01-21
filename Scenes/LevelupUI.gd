extends "res://Scripts/draggable_window.gd"

@onready var optionButton_1 = $Option1
@onready var optionButton_2 = $Option2
@onready var optionButton_3 = $Option3

# holds the upgrade options
# assume size is 3
var options = []

var connected: bool = false


func _ready():
	$PassButton.pressed.connect(_on_pass_button_pressed)


func _process(delta):
	super._process(delta)
	
	if connected == false:
		Game.survivor.level_up.connect(on_level_up)
		connected = true
		

func on_level_up():
	# show this window
	visible = true
	# stop time
	Engine.time_scale = 0
	# generate upgrade options
	DataManager.survivorUpgradeResources.shuffle()
	options = DataManager.survivorUpgradeResources.slice(0,3)
	# update ui
	SetOptions(options)
	
	
func SetOptions(newOptions):
	options = newOptions
	
	# update UI
	optionButton_1.text = newOptions[0].name
	optionButton_1.get_node("Description").text = newOptions[0].description
	optionButton_2.text = newOptions[1].name
	optionButton_2.get_node("Description").text = newOptions[1].description
	optionButton_3.text = newOptions[2].name
	optionButton_3.get_node("Description").text = newOptions[2].description
	
	
func _upgrade_option_selected(num):
	# hide this window
	visible = false
	Engine.time_scale = 1
	Game.survivor.LevelUp()
	print("Upgrade " + options[num].name + " selected!")
	Game.survivor.AddUpgrade(options[num])


func _on_pass_button_pressed():
	# hide this window
	visible = false
	Game.survivor.AddExperiencePoints( - Game.survivor.experiencePoints * 0.5 )
	Engine.time_scale = 1
	
