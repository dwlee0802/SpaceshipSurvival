extends Button

var dragging: bool = false
var dragStart
var screenDragOffset


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# dragging
	if dragging:
		position = get_global_mouse_position() - screenDragOffset


func _on_button_down():
	dragging = true
	dragStart = position
	screenDragOffset = get_local_mouse_position()
	
func _on_button_up():
	dragging = false
	
