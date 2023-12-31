extends Control

@onready var label = $AmmoLabel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position = get_global_mouse_position()
	label.text = str(Game.survivor.magazineCount)
