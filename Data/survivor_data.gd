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

@export var startingPrimary: Weapon
