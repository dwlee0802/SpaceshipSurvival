extends DraggableItemSlot

var placedItem = preload("res://Scenes/placed_item.tscn")

# the item is dropped
# make placed item object
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var newPlacedItem = placedItem.instantiate()
	newPlacedItem.item = data.item
	Game.gameScene.add_child(newPlacedItem)
	newPlacedItem.global_position = Game.survivor.global_position + Vector2(randi_range(-25,25), randi_range(-25,25))
	data.reparent(self)
	data.queue_free()
	
	emit_signal("item_dropped")
