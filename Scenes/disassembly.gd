extends Interactable
class_name Disassembly

var isOperational: bool = true


func Fix(delta):
	super.Fix(delta)
	# show disassembly UI
	UserInterfaceManager.disassemblyUI.visible = true
