extends Weapon
class_name RangedWeapon

@export var ammoPerReload: int
@export var reloadTime: float
@export var magazineCapacity: int

@export var projectileSpeed: float = 900.0

# modify spread by this amount if moving
@export var movementPenalty: float = 1

@export var isLaserWeapon: bool = false
