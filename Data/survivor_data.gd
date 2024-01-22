extends Resource
class_name SurvivorData

@export var name: String
@export var profileTexture: Texture
@export var spriteTexture: Texture

# base stats
@export var speed: float = 200
@export var accuracy: float
@export var strength: float
@export var maxHealth: float
@export var defense: float
@export var radiationDefense: float
@export var luck: int

# needs
@export var maxOxygen: int = 100
@export var maxNutrition: int = 100
@export var maxSleep: int = 100
@export var maxWater: int = 100


@export var startingPrimary: Weapon

@export var skill_1: Skill
@export var skill_2: Skill
@export var skill_3: Skill
@export var skill_4: Skill
