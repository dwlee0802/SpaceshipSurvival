extends Interactable
class_name Disassembly

var isOperational: bool = true

var showUI: bool = false


func _process(delta):
	if showUI:
		UserInterfaceManager.disassemblyUI.visible = true
	else:
		UserInterfaceManager.disassemblyUI.visible = false
		
	showUI = false
	

func Fix(delta):
	# show disassembly UI
	showUI = true
	return false
