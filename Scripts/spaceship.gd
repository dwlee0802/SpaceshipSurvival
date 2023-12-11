extends Node

class_name Spaceship

# Oxygen level of the ship.
# Affects how much oxygen is gained per breath
# Might change this to module specific levels in the future
# if a unit reaches zero oxygen, they take HP damage
static var oxygenLevel: int = 100

# temperature level of the ship
# body temperature of survivors slowly change towards ship temperature
# if too high or low, speed and accuracy is decreased and HP is slowly reduced
static var temperature: float = 40

# food stock of the survivors
# food is consumed periodically
# if nutrition is zero, speed is reduced and lose HP
static var foodStock: int = 0
static var maxFoodStock: int = 0

# ammo stock of the survivors
# ammo is consumed when using ranged weapons
# more powerful weapons consume more ammo
# can't use ranged weapons if ammo is zero
static var ammoStock: int = 1000
static var maxAmmoStock: int = 0

# component stock of the survivors
# components are used to make gear and fix modules
# components are earned by dismantling gear or looting
static var componentStock: int = 10
static var maxComponentStock: int = 10

# the travel speed of the ship
# calculated based on the number of operational thrusters
# added every second to distance traveled. When it reaches a certain amount, the player wins
static var shipSpeed: int = 1
static var distanceTraveled: int = 0
static var DISTANCE_TO_DESTINATION: int = 36000

@export var modules = {}

enum ModuleName {Nuclear_Reactor, Oxygen_Generator, Temperature_Control, Infirmary, Kitchen, Bridge, Engine_Room, Electricity_Room}

signal destination_reached

static var spaceship

# Called when the node enters the scene tree for the first time.
func _ready():
	spaceship = self
	modules[ModuleName.Oxygen_Generator] = $Modules/OxygenGenerator
	modules[ModuleName.Temperature_Control] = $Modules/TemperatureControl
	modules[ModuleName.Nuclear_Reactor] = $Modules/NuclearReactor
	#modules[ModuleName.Infirmary] = $Modules/Infirmary
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Game.UpdateStockMax()
	UserInterfaceManager.UpdateAmmoStockLabel(ammoStock)
	UserInterfaceManager.UpdateFoodStockLabel(foodStock)
	UserInterfaceManager.UpdateComponentStockLabel(componentStock)


func _on_travel_timer_timeout():
	distanceTraveled += shipSpeed
	if distanceTraveled > DISTANCE_TO_DESTINATION:
		distanceTraveled = DISTANCE_TO_DESTINATION
	
	UserInterfaceManager.UpdateTravelProgressUI(distanceTraveled, DISTANCE_TO_DESTINATION)
	
	if distanceTraveled == DISTANCE_TO_DESTINATION:
		emit_signal("destination_reached")


func _on_temperature_timer_timeout():
	if not modules[ModuleName.Temperature_Control].isOperational:
		temperature -= 0.1
	elif temperature < 25:
		temperature += 0.1
	
	UserInterfaceManager.UpdateSpaceshipStatusUI(oxygenLevel, temperature)


func _on_oxygen_timer_timeout():
	if not modules[ModuleName.Oxygen_Generator].isOperational:
		oxygenLevel -= 1
	else:
		oxygenLevel += 2
	
	if oxygenLevel < 0:
		oxygenLevel = 0
	if oxygenLevel > 100:
		oxygenLevel = 100
	
	UserInterfaceManager.UpdateSpaceshipStatusUI(oxygenLevel, temperature)


static func ConsumeAmmo(amount):
	if amount > ammoStock:
		UserInterfaceManager.UpdateAmmoStockLabel(ammoStock)
		return false
	else:
		ammoStock -= amount
	
	if ammoStock < 0:
		ammoStock = 0
		
	UserInterfaceManager.UpdateAmmoStockLabel(ammoStock)
	return true


static func ConsumeFood(amount):
	if amount > foodStock:
		UserInterfaceManager.UpdateFoodStockLabel(foodStock)
		return false
	else:
		foodStock -= amount
	
	if foodStock < 0:
		foodStock = 0
		
	UserInterfaceManager.UpdateFoodStockLabel(foodStock)
	return true


static func ConsumeComponents(amount):
	if amount > componentStock:
		UserInterfaceManager.UpdateComponentStockLabel(componentStock)
		return false
	else:
		componentStock -= amount
	
	if componentStock < 0:
		componentStock = 0
		
	UserInterfaceManager.UpdateComponentStockLabel(componentStock)
	return true


static func PrintModuleStatus():
	var output = "Modules\n"
	
	for module in Spaceship.spaceship.get_node("Modules").get_children():
		output += module.name + ": "
		if module.isOperational:
			output += "Normal\n"
		else:
			output += "ERROR!\n"
	
	return output
