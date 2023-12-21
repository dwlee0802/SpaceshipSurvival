extends Interactable
class_name CraftingStation

var isOperational: bool = true

var showUI: bool = false
	

func Fix(delta):
	# show disassembly UI
	showUI = true
	return true

