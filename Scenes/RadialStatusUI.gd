extends Control

@onready var nutritionBar = $NutritionBar
@onready var oxygenBar = $OxygenBar
@onready var sleepBar = $SleepBar
@onready var tempBar = $TemperatureBar
@onready var thirstBar = $ThirstBar


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var nutrition = int(Game.survivor.nutrition)
	if nutrition >= 0 and nutrition <= 100:
		nutritionBar.progress = nutrition
		nutritionBar.get_node("Label").text = str(int(nutritionBar.progress)) + "%"
		
	var oxygen = int(Game.survivor.oxygen)
	if oxygen >= 0 and oxygen <= 100:
		oxygenBar.progress = oxygen
		oxygenBar.get_node("Label").text = str(int(oxygenBar.progress)) + "%"
		
	var sleep = int(Game.survivor.sleep)
	if sleep >= 0 and sleep <= 100:
		sleepBar.progress = sleep
		sleepBar.get_node("Label").text = str(int(sleepBar.progress)) + "%"
		
	var water = int(Game.survivor.water)
	if water >= 0 and water <= 100:
		thirstBar.progress = water
		thirstBar.get_node("Label").text = str(int(thirstBar.progress)) + "%"
