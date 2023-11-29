extends Node

class_name UserInterfaceManager

static var travelProgressUI

static var spaceshipStatusUI

static var healthBar

static var oxygenBar

static var temperatureBar

static var sleepBar

static var nutritionBar

static var BAR_LENGTH = 200

static var unitUI

# Called when the node enters the scene tree for the first time.
func _ready():
	travelProgressUI = $TravelProgressUI
	spaceshipStatusUI = $SpaceshipStatusUI
	healthBar = $UnitUI/HealthBar/TextureRect
	oxygenBar = $UnitUI/OxygenBar/TextureRect
	temperatureBar = $UnitUI/TemperatureBar/TextureRect
	sleepBar = $UnitUI/SleepBar/TextureRect
	nutritionBar = $UnitUI/NutritionBar/TextureRect
	unitUI = $UnitUI


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# change scale x of progress bar based on progress
static func UpdateTravelProgressUI(cur, max):
	var maxSize = travelProgressUI.get_node("Background").size.x
	
	travelProgressUI.get_node("ProgressBar").size.x = maxSize * cur / max
	travelProgressUI.get_node("SpaceshipIcon").position.x = maxSize * cur / max - 2
	
	travelProgressUI.get_node("SpaceshipIcon/ProgressPercentLabel").text = str(int(float(cur)/max * 100)) + "%"


# change ship status UI info
static func UpdateSpaceshipStatusUI(oxygen, temp):
	spaceshipStatusUI.get_node("OxygenLevel/Label").text = str(oxygen) + "%"
	spaceshipStatusUI.get_node("TemperatureLevel/Label").text = str(temp) + "C"
	
	
static func UpdateUnitUI(unit):
	healthBar.size.x = unit.health / unit.maxHealth * BAR_LENGTH
	oxygenBar.size.x = unit.oxygen / 100 * BAR_LENGTH
	temperatureBar.size.x = unit.bodyTemperature / 50 * BAR_LENGTH
	sleepBar.size.x = unit.sleep / 600 * BAR_LENGTH
	nutritionBar.size.x = unit.nutrition / 100 * BAR_LENGTH


static func ToggleUnitUI(val):
	unitUI.visible = val


func _on_unit_info_button_pressed(extra_arg_0):
	print("pressed ", extra_arg_0)


func _on_inventory_list_item_clicked(index, at_position, mouse_button_index):
	pass # Replace with function body.
