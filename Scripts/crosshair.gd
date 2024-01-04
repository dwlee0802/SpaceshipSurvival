extends Control

@onready var label = $AmmoLabel
@onready var image = $TextureRect

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
	label.text = str(Game.survivor.magazineCount)
	ApplySpread()


# increase size based on survivor's spread
# base size is 50. increase to 150
# size is 50 at 0 spread and 150 at 180 spread
func ApplySpread():
	var survivor = Game.survivor
	var newSize = 50 + 100 * survivor.spread * 57 / 45
	image.size = Vector2(newSize, newSize)
	# center image
	image.position = Vector2(-newSize / 2, -newSize / 2)
