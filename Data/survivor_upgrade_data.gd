extends Upgrade
class_name SurvivorUpgrade

# combat parameters
@export var health: int = 0
@export var speed: int = 0
@export var defense: float = 0
@export var radiationDefense: float = 0
@export var accuracyModifier: float = 0
@export var attackSpeedModifier: float = 0
@export var runningSpeedModifier: float = 0

# needs parameters
# added to unit's modifier
@export var nutritionConsumptionModifier: float = 0
@export var waterConsumptionModifier: float = 0
@export var oxygenConsumptionModifier: float = 0
@export var sleepConsumptionModifier: float = 0
@export var runningOxygenConsumptionModifier: float = 0
@export var runningWaterConsumptionModifier: float = 0

# others
@export var luck: int = 0
@export var inventoryCapIncrease: int = 0
