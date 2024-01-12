extends Interactable
class_name Disassembly


var showUI: bool = false
	
	
func _process(delta):
	super._process(delta)
	

func Fix(delta):
	# show disassembly UI
	showUI = true
	return true
