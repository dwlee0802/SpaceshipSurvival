extends Upgrade
class_name SurvivorUpgrade

# combat parameters
@export var health: int = 0
@export var speed: int = 0
@export var defense: float = 0
@export var radiationDefense: float = 0
@export var accuracyModifier: float = 1
@export var attackSpeedModifier: float = 1
@export var runningSpeedModifier: float = 1

# needs parameters
@export var nutritionConsumptionModifier: float = 1
@export var waterConsumptionModifier: float = 1
@export var oxygenConsumptionModifier: float = 1
@export var sleepConsumptionModifier: float = 1

# others
@export var luck: int = 0
@export var inventoryCapIncrease: int = 0
