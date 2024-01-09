extends Panel

@onready var ammoLabel = $AmmoCountLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Game.survivor.primarySlot.data is RangedWeapon:
		ammoLabel.visible = true
		ammoLabel.text = str(Game.survivor.primarySlot.currentAmmo) + " / " + str(Game.survivor.primarySlot.data.magazineCapacity) + " (" + str(Game.survivor.primarySlot.totalAmmo) + ")"
	else:
		ammoLabel.visible = false
