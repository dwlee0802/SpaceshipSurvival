extends Node2D

var selectedUnits = []

var dragging: bool = false
var drag_start = Vector2.ZERO

@onready var selectionBox = $SelectionBox


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = event.position
				selectedUnits = []
			if event.is_released():
				dragging = false
				selectionBox.visible = false
				selectedUnits = selectionBox.get_overlapping_bodies()
				
			
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			for unit in selectedUnits:
				unit.target_position = event.position
		
		
	if dragging and event is InputEventMouseMotion:
		DrawSelectionBox(drag_start, event.position)
		selectionBox.visible = true
			

func DrawSelectionBox(start, end):
	var width = abs(end.x - start.x)
	var height = abs(end.y - start.y)
	
	var center = Vector2((start.x + end.x)/2, (start.y + end.y)/2)
	selectionBox.position = center
	
	var box = selectionBox.get_node("Sprite2D")
	box.scale = Vector2(width, height)
	box.position = center
	
	var area = selectionBox.get_node("CollisionShape2D")
	area.shape.size = Vector2(width, height)
	
