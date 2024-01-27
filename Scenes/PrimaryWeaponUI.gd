extends Button
class_name WeaponUI

@onready var ammoLabel = $AmmoCountLabel
@onready var upgradeAvailableIndicator = $UpgradeAvailableIndicator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Game.survivor.primarySlot != null and Game.survivor.primarySlot.data is RangedWeapon and Game.survivor.primarySlot is Gun:
		ammoLabel.visible = true
		ammoLabel.text = str(Game.survivor.primarySlot.currentAmmo) + " / " + str(Game.survivor.primarySlot.data.magazineCapacity) + " (" + str(Game.survivor.primarySlot.totalAmmo) + ")"
	else:
		ammoLabel.visible = false
		
	# at least one upgrade available
	upgradeAvailableIndicator.visible = WeaponUpgradeUI.upgradeAvailable



func _pressed():
	if UserInterfaceManager.weaponUpgradeUI.visible == true:
		UserInterfaceManager.weaponUpgradeUI.visible = false
	else:
		# open ui menu	
		UserInterfaceManager.weaponUpgradeUI.visible = true
		UserInterfaceManager.weaponUpgradeUI.UpdateUI()
