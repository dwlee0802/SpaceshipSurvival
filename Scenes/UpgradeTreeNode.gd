extends TextureButton
class_name UpgradeTreeNode

@export var tree : int = 0
@export var node : int = 0

var componentCost: int = 0

func _pressed():
	var upgradeUI = get_parent().get_parent().UpgradeSelected(tree, node)
	
