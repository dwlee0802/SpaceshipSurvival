extends Resource
class_name Skill

@export var name: String
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D
@export var cooldownTime: float = 0
@export var duration: float = 0

func Effect(user, target = null):
	print("used skill " + name)
