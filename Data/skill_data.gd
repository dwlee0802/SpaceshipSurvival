class_name SkillData
extends Resource

enum SkillType {SelfBuff, AreaBuff, EnemyDebuff, Projectile, Defensive}

@export var type: SkillType
@export var name: String
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D
@export var cooltime: float = 0
@export var duration: float = 0

# instantiate this if type is projectile
@export var effectScene: Resource

func Effect(user, target = null):
	print("used skill " + name)
