extends ItemData
class_name Weapon

@export var range: int
@export var minDamage: int
@export var maxDamage: int
@export var attacksPerSecond: float
@export var penetration: float
@export var accuracy: float
@export var knockBack: int

@export var attack_sound: AudioStream

@export var upgradeBaseCost: int = 100

# upgrade tress
@export var upgradeTree_0: UpgradeTree
var upgradeTree_0_selected = [false, false, false, false, false, false]
@export var upgradeTree_1: UpgradeTree
var upgradeTree_1_selected = [false, false, false, false, false, false]
@export var upgradeTree_2: UpgradeTree
var upgradeTree_2_selected = [false, false, false, false, false, false]
