extends Interactable
class_name CraftingStation

var isOperational: bool = true

var showUI: bool = false


func _process(delta):
	super._process(delta)
	

func Fix(delta):
	# show disassembly UI
	showUI = true
	return true

