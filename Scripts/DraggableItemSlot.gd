extends Control
class_name DraggableItemSlot

@export var type: Type = Type.Null

enum {Melee, Ranged, Head, Body, Consumable}
enum Type {Head, Body, Primary, Secondary, Null}

var mouseOnThis: bool = false


func _process(delta):
	if mouseOnThis:
		self_modulate = Color.AQUA
	else:
		self_modulate = Color.WHITE
		self_modulate.a = 0.4
		
		
func _can_drop_data(at_position, data):
	if type == Type.Null:
		return true
	elif type == Type.Head and data.item.type == ItemType.Head:
		return true
	elif type == Type.Body and data.item.type == ItemType.Body:
		return true
	elif type == Type.Primary and (data.item.type == ItemType.Ranged or data.item.type == ItemType.Melee):
		return true
	else:
		return false
		
		
# the item is dropped
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if get_child_count() > 0:
		var item := get_child(0)
		if item == data:
			return
		item.reparent(data.get_parent())
	data.reparent(self)
	data.position = Vector2.ZERO

