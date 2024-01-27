extends "res://Scripts/draggable_window.gd"
class_name WeaponUpgradeUI

@onready var tree_0 = $Tree_0
var tree_0_nodes = []
@onready var tree_1 = $Tree_1
var tree_1_nodes = []
@onready var tree_2 = $Tree_2
var tree_2_nodes = []

var initialized: bool = false


# make references to the nodes in the tree
func _ready():
	for item in tree_0.get_children():
		if item is UpgradeTreeNode:
			tree_0_nodes.append(item)
	for item in tree_1.get_children():
		if item is UpgradeTreeNode:
			tree_1_nodes.append(item)
	for item in tree_2.get_children():
		if item is UpgradeTreeNode:
			tree_2_nodes.append(item)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if initialized == false:
		UpdateUI()
		initialized = true
		

# make weapon upgrade tree UI
func UpdateUI():
	var currentWeapon = Game.survivor.primarySlot.data
	var currentWeaponUpgrades
	
	# update tree 0 if it exists
	if currentWeapon is Weapon:
		if currentWeapon.upgradeTree_0 != null:
			for i in range(len(tree_0_nodes)):
				#tree_0_nodes[i].texture_normal = currentWeapon.upgradeTree_0.upgradeNodes[i].texture
				tree_0_nodes[i].set_tooltip_text(str(currentWeapon.upgradeTree_0.upgradeNodes[i]))
				
				if currentWeapon.upgradeTree_0_selected[i]:
					tree_0_nodes[i].disabled = true
					continue
					
				tree_0_nodes[i].disabled = true
				
				# enable nodes
				# enable if has enough components to select it
				# and previous node is selected
				if i == 0 or i == 1:
					if Game.survivor.components >= currentWeapon.upgradeBaseCost:
						tree_0_nodes[i].disabled = false
				
				if i == 2:
					tree_0_nodes[i].componentCost = currentWeapon.upgradeBaseCost * 1.5
					if Game.survivor.components >= tree_0_nodes[i].componentCost:
						if currentWeapon.upgradeTree_0_selected[0] or  currentWeapon.upgradeTree_0_selected[1]:
							tree_0_nodes[i].disabled = false
						
				if i == 3 or i == 4:
					tree_0_nodes[i].componentCost = currentWeapon.upgradeBaseCost * 2
					if Game.survivor.components >= currentWeapon.upgradeBaseCost * 2:
						if currentWeapon.upgradeTree_0_selected[2]:
							tree_0_nodes[i].disabled = false
						
				if i == 5:
					tree_0_nodes[i].componentCost = currentWeapon.upgradeBaseCost * 2.5
					if Game.survivor.components >= currentWeapon.upgradeBaseCost * 2.5:
						if currentWeapon.upgradeTree_0_selected[3] or currentWeapon.upgradeTree_0_selected[4]:
							tree_0_nodes[i].disabled = false
				
					
		if currentWeapon.upgradeTree_1 != null:
			for i in range(len(tree_1_nodes)):
				#tree_0_nodes[i].texture_normal = currentWeapon.upgradeTree_0.upgradeNodes[i].texture
				tree_1_nodes[i].tooltip_text = str(currentWeapon.upgradeTree_1.upgradeNodes[i])
				tree_1_nodes[i].disabled = true
		if currentWeapon.upgradeTree_2 != null:
			for i in range(len(tree_2_nodes)):
				#tree_0_nodes[i].texture_normal = currentWeapon.upgradeTree_0.upgradeNodes[i].texture
				tree_2_nodes[i].tooltip_text = str(currentWeapon.upgradeTree_2.upgradeNodes[i])
				tree_2_nodes[i].disabled = true
				
	

func UpgradeSelected(tree, num):
	var currentWeapon : Weapon = Game.survivor.primarySlot.data
	print("upgrade tree " + str(tree) + "'s " + str(num) + " node selected")
	if tree == 0:
		currentWeapon.upgradeTree_0_selected[num] = true
	UpdateUI()
