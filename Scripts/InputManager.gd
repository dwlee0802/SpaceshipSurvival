extends Node2D

var selectedUnits = []

var dragging: bool = false
var drag_start = Vector2.ZERO

@onready var selectionBox = $SelectionBox


func _process(delta):
	if len(selectedUnits) == 1:
		UserInterfaceManager.ToggleUnitUI(true)
		UserInterfaceManager.UpdateUnitUI(selectedUnits[0])
	else:
		UserInterfaceManager.ToggleUnitUI(false)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = get_global_mouse_position()
			if event.is_released():
				Game.SetSelectionUI(false)
				dragging = false
				selectionBox.visible = false
				selectedUnits = selectionBox.get_overlapping_bodies()
				selectionBox.get_node("CollisionShape2D").disabled = true
				for item in selectedUnits:
					item.ShowSelectionUI()
			
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				
			# Raytrace at mouse position and get tile
			var space = get_viewport().world_2d.direct_space_state
			var param = PhysicsPointQueryParameters2D.new()
			param.position = get_global_mouse_position()
			param.collision_mask = 4
			var result = space.intersect_point(param)
			
			# No map opjects. Just move there directly
			if len(result) == 0:
				for unit in selectedUnits:
					unit.ChangeTargetPosition( get_global_mouse_position() )
					unit.interactionTarget = null
			else:
				print("selected map object")
				for unit in selectedUnits:
					unit.ChangeTargetPosition( result[0].collider.interactionPoint.global_position )
					unit.interactionTarget = result[0].collider
					
			Game.UpdateEnemyTargetPosition()
				
		
	if dragging and event is InputEventMouseMotion:
		selectionBox.get_node("CollisionShape2D").disabled = false
		DrawSelectionBox(drag_start, get_global_mouse_position())
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
	

func _on_move_and_shoot_toggled(button_pressed):
	if len(selectedUnits) > 0:
		for unit in selectedUnits:
			unit.moveAndShoot = button_pressed


func _on_fire_at_will_toggled(button_pressed):
	if len(selectedUnits) > 0:
		for unit in selectedUnits:
			unit.fireAtWill = button_pressed
			

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		UserInterfaceManager.CheckContextMenuVisibility()
		UserInterfaceManager.ModifyContextMenuByItem(selectedUnits[0].inventory[index])
		

func _on_information_button_pressed():
	if len(selectedUnits) > 0:
		UserInterfaceManager.ToggleUnitInfoPanel(selectedUnits[0])


func _on_equip_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	
