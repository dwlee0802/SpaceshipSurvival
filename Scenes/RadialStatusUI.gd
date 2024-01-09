extends Control

@onready var nutritionBar = $NutritionBar
@onready var oxygenBar = $OxygenBar
@onready var sleepBar = $SleepBar
@onready var tempBar = $TemperatureBar
@onready var thirstBar = $ThirstBar


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	nutritionBar.progress = Game.survivor.nutrition
	oxygenBar.progress = Game.survivor.oxygen
	sleepBar.progress = Game.survivor.sleep
	tempBar.progress = 50 + (Game.survivor.bodyTemperature - 36.5)
	thirstBar.progress = Game.survivor.water
