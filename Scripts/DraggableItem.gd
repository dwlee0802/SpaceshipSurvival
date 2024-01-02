extends TextureButton
class_name DraggableItem

var mouse_offset: Vector2 = Vector2.ZERO

var dragging: bool = false

var item: Item

var previousSlot


func _ready():
	if item.data.texture != null:
		texture_normal = item.data.texture


func make_drag_preview(at_position: Vector2) -> Control:
	var t := TextureRect.new()
	t.texture = texture_normal
	t.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	t.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	t.custom_minimum_size = size
	t.modulate.a = 0.5
	t.position = Vector2(-at_position)

	var c := Control.new()
	c.add_child(t)

	return c
	
	
func _get_drag_data(at_position: Vector2) -> Variant:
	set_drag_preview(make_drag_preview(at_position))
	previousSlot = get_parent()
	return self


# use button on right click
func _on_pressed():
	InputManager.UseInventoryItem(self)
