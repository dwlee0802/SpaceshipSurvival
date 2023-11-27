extends Node

# Oxygen level of the ship.
# Affects how much oxygen is gained per breath
# Might change this to module specific levels in the future
# if a unit reaches zero oxygen, they take HP damage
static var oxygenLevel: int = 100

# temperature level of the ship
# body temperature of survivors slowly change towards ship temperature
# if too high or low, speed and accuracy is decreased and HP is slowly reduced
static var temperature: int = 25

# food stock of the survivors
# food is consumed periodically
# if nutrition is zero, speed is reduced and lose HP
static var foodStock: int = 0

# the travel speed of the ship
# calculated based on the number of operational thrusters
# added every second to distance traveled. When it reaches a certain amount, the player wins
static var shipSpeed: int = 10
static var distanceTraveled: int = 0
static var DISTANCE_TO_DESTINATION: int = 36000

@export var modules = []

enum ModuleName {Nuclear_Reactor, Life_Support, Infirmary, Kitchen, Bridge, Engine_Room, Electricity_Room}

signal destination_reached


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_travel_timer_timeout():
	distanceTraveled += shipSpeed
	if distanceTraveled > DISTANCE_TO_DESTINATION:
		distanceTraveled = DISTANCE_TO_DESTINATION
	
	UserInterfaceManager.UpdateTravelProgressUI(distanceTraveled, DISTANCE_TO_DESTINATION)
	
	if distanceTraveled == DISTANCE_TO_DESTINATION:
		emit_signal("destination_reached")


func _on_temperature_timer_timeout():
	pass # Replace with function body.


func _on_oxygen_timer_timeout():
	pass # Replace with function body.
