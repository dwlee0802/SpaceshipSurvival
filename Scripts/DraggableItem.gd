extends TextureButton

var mouse_offset: Vector2 = Vector2.ZERO

var previousPosition: Vector2

var dragging: bool = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if dragging:
		position = get_global_mouse_position() - mouse_offset


func _on_button_down():
	dragging = true
	mouse_offset = get_global_mouse_position() - position
	self_modulate.a = 0.5
	previousPosition = position


func _on_button_up():
	dragging = false
	# raycast and see if the slot is appropriate
	# return to previous location if invalid spot
	position = previousPosition
	self_modulate.a = 1
