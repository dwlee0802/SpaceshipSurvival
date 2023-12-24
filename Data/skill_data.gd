class_name SkillData
extends Resource

enum SkillType {SelfBuff, AreaBuff, EnemyDebuff, Projectile, Defensive}

@export var name: String
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D
@export var cooltime: float = 0
@export var duration: float = 0


func SkillEffect(user, target = null):
	print("used skill " + name)
