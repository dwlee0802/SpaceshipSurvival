extends Resource
class_name Upgrade

@export var name: String = "NULL"
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D

# upgrade parameters
@export var health: int = 0
@export var speed: int = 0
@export var defense: int = 0
@export var accuracy: float = 0
