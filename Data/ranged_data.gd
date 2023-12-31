extends Weapon
class_name RangedWeapon

@export var ammoPerReload: int
@export var reloadTime: float
@export var magazineCapacity: int

# modify spread by this amount if moving
@export var movementPenalty: float = 1
