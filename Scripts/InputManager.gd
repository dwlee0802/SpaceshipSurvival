extends Node2D

var selectedUnits = []

var placedItem = preload("res://Scenes/placed_item.tscn")

var dragging: bool = false
var drag_start = Vector2.ZERO

@onready var selectionBox = $SelectionBox


func _process(delta):
	if len(selectedUnits) == 1:
		UserInterfaceManager.ToggleUnitUI(true)
		UserInterfaceManager.UpdateUnitBarUI(selectedUnits[0])
		UserInterfaceManager.UpdateUnitInfoUI(selectedUnits[0])
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
				if len(selectedUnits) > 0:
					if not selectedUnits[0].update_unit_ui.is_connected(UpdateUnitUI):
						selectedUnits[0].update_unit_ui.connect(UpdateUnitUI)
						
					UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])
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
					unit.interactionContainer = null
			else:
				for unit in selectedUnits:
					if result[0].collider is Interactable:
						unit.ChangeTargetPosition( result[0].collider.interactionPoint.global_position )
						print("selected interactable")
					if result[0].collider is PlacedItem:
						unit.ChangeTargetPosition( result[0].collider.global_position )
						print("selected item")
					if result[0].collider is ItemContainer:
						unit.ChangeTargetPosition( result[0].collider.interactionPoint.global_position )
						
					unit.interactionTarget = result[0].collider
			
			UpdateUnitUI()
					
			Game.UpdateEnemyTargetPosition()
		
	if event is InputEventKey:
		if event.pressed:
			# pan camera to survivors
			if event.keycode == KEY_1:
				if len(Game.survivors) >= 1:
					SelectSingleUnit(Game.survivors[0])
			if event.keycode == KEY_2:
				if len(Game.survivors) >= 2:
					SelectSingleUnit(Game.survivors[1])
			if event.keycode == KEY_3:
				if len(Game.survivors) >= 2:
					SelectSingleUnit(Game.survivors[2])
			if event.keycode == KEY_4:
				if len(Game.survivors) >= 3:
					SelectSingleUnit(Game.survivors[3])
			
			# show spaceship overview UI
			if event.keycode == KEY_TAB:
				UserInterfaceManager.UpdateSpaceshipOverviewUI()
				
			# pause button
			if event.keycode == KEY_SPACE:
				if Engine.time_scale == 0:
					Engine.time_scale = 1
				else:
					Engine.time_scale = 0
		else:
			# show spaceship overview UI
			if event.keycode == KEY_TAB:
				UserInterfaceManager.UpdateSpaceshipOverviewUI(false)
		
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
		UserInterfaceManager.ModifyContextMenuByItem(index, selectedUnits[0])
		

func _on_information_button_pressed():
	if len(selectedUnits) > 0:
		UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])


func _on_equip_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	
	var itemType = selectedUnits[0].inventory[selectedItemIndex].type
	
	var slotType
	
	# equip weapon
	if itemType == ItemType.Melee or itemType == ItemType.Ranged:
		slotType = SlotType.Primary
	
	# equip armor
	if itemType == ItemType.Head:
		slotType = SlotType.Head
	if itemType == ItemType.Body:
		slotType = SlotType.Body
	
	selectedUnits[0].EquipItemFromInventory(selectedItemIndex, slotType)
	selectedUnits[0].UpdateStats()
	
	UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])
	
	
func UpdateUnitUI():
	if len(selectedUnits) > 0:
		UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])


func SelectSingleUnit(unit):
	Game.SetSelectionUI(false)
	selectedUnits = []
	selectedUnits.append(unit)
	unit.ShowSelectionUI()
	if not unit.update_unit_ui.is_connected(UpdateUnitUI):
		unit.update_unit_ui.connect(UpdateUnitUI)
	UserInterfaceManager.UpdateUnitInfoPanel(unit)


func _on_unequip_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	var itemType = selectedUnits[0].inventory[selectedItemIndex].type
	var slotType
	
	# equip weapon
	if itemType == ItemType.Melee or itemType == ItemType.Ranged:
		slotType = SlotType.Primary
	
	# equip armor
	if itemType == ItemType.Head:
		slotType = SlotType.Head
	if itemType == ItemType.Body:
		slotType = SlotType.Body

	selectedUnits[0].equipmentSlots[slotType] = -1
	
	selectedUnits[0].UpdateStats()
	
	UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])


func _on_drop_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	var newItem = placedItem.instantiate()
	var removed = selectedUnits[0].RemoveByIndex(selectedItemIndex)
	newItem.itemType = removed.type
	newItem.itemID = removed.data.ID
	newItem.position = selectedUnits[0].position
	add_sibling(newItem)
	
	selectedUnits[0].UpdateStats()
	UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])


func _on_consume_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	var data = selectedUnits[0].inventory[selectedItemIndex].data
	
	Spaceship.ConsumeAmmo( -data.ammo)
	Spaceship.ConsumeFood( -data.food)
	
	selectedUnits[0].HealHealth(data.heal * selectedUnits[0].maxHealth)
	
	selectedUnits[0].RemoveByIndex(selectedItemIndex)
	
	selectedUnits[0].UpdateStats()
	UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])
	

func _on_take_button_pressed(isTake):
	if len(selectedUnits) < 1:
		return
	if selectedUnits[0].interactionContainer == null:
		return
		
		
	if isTake:
		var containerItemList = UserInterfaceManager.containerUI.get_node("ItemList")
		if len(containerItemList.get_selected_items()) == 0:
			print("nothing selected!")
			return
		var itemContainer = selectedUnits[0].interactionContainer
		var index: int = containerItemList.get_selected_items()[0]
		selectedUnits[0].AddItem(itemContainer.RemoveItemByIndex(index))
	else:
		var selectedItemIndex = UserInterfaceManager.itemList.get_selected_items()
		if len(selectedItemIndex) == 0:
			print("nothing selected!")
			return
		var itemContainer = selectedUnits[0].interactionContainer
		if itemContainer.AddItem(selectedUnits[0].inventory[selectedItemIndex[0]]):
			selectedUnits[0].RemoveByIndex(selectedItemIndex[0])
		else:
			print("Cannot put because container is full!")
		

	selectedUnits[0].UpdateStats()
	UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])
