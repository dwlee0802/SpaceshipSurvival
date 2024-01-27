extends Resource
class_name UpgradeTree

@export var name: String
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D

# upgrade nodes
# nodes are ordered top left to bottom right
@export var upgradeNodes = []
