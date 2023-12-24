class_name SkillData
extends Resource

enum SkillType {SelfBuff, AreaBuff, EnemyDebuff, Offensive, Defensive}

@export var name: String
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D
@export var cooltime: float


func SkillEffect(user, target = null):
	print("used skill " + name)
