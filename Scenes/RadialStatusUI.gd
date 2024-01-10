extends Control

@onready var nutritionBar = $NutritionBar
@onready var oxygenBar = $OxygenBar
@onready var sleepBar = $SleepBar
@onready var tempBar = $TemperatureBar
@onready var thirstBar = $ThirstBar


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var nutrition = int(Game.survivor.nutrition)
	if nutrition != 0:
		nutritionBar.progress = nutrition
		
	var oxygen = int(Game.survivor.oxygen)
	if oxygen != 0:
		oxygenBar.progress = oxygen
		
	var sleep = int(Game.survivor.sleep)
	if sleep != 0:
		sleepBar.progress = sleep
		
	var water = int(Game.survivor.water)
	if water != 0:
		thirstBar.progress = water
		
	oxygenBar.progress = int(Game.survivor.oxygen)
	sleepBar.progress = int(Game.survivor.sleep)
	#tempBar.progress = 50 + (Game.survivor.bodyTemperature - 36.5)
	thirstBar.progress = int(Game.survivor.water)
