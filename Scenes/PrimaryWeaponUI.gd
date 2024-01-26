extends Panel
class_name WeaponUI

@onready var ammoLabel = $AmmoCountLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Game.survivor.primarySlot != null and Game.survivor.primarySlot.data is RangedWeapon and Game.survivor.primarySlot is Gun:
		ammoLabel.visible = true
		ammoLabel.text = str(Game.survivor.primarySlot.currentAmmo) + " / " + str(Game.survivor.primarySlot.data.magazineCapacity) + " (" + str(Game.survivor.primarySlot.totalAmmo) + ")"
	else:
		ammoLabel.visible = false
