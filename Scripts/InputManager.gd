extends Node2D
class_name InputManager

static var selectedUnits = []

var placedItem = preload("res://Scenes/placed_item.tscn")

var dragging: bool = false
var drag_start = Vector2.ZERO

var lockOn: bool = false

@onready var selectionBox = $SelectionBox


func _ready():
	# connect slots
	var inventoryGrid = UserInterfaceManager.inventoryGrid
	var containerGrid = UserInterfaceManager.containerGrid
	for i in range(inventoryGrid.get_child_count()):
		inventoryGrid.get_child(i).item_dropped.connect(ApplyUnitInventory)
	UserInterfaceManager.inventoryUI.get_node("HeadSlot/DraggableItem").item_dropped.connect(ApplyUnitInventory)
	UserInterfaceManager.inventoryUI.get_node("BodySlot/DraggableItem").item_dropped.connect(ApplyUnitInventory)
	UserInterfaceManager.inventoryUI.get_node("PrimarySlot/DraggableItem").item_dropped.connect(ApplyUnitInventory)
	UserInterfaceManager.inventoryUI.get_node("DropSlot/DraggableItem").item_dropped.connect(ApplyUnitInventory)
	for i in range(containerGrid.get_child_count()):
		containerGrid.get_child(i).item_dropped.connect(ApplyUnitInventory)
	
	# connect disassembly slot and ui update
	UserInterfaceManager.disassemblyUI.get_node("DraggableItemSlot").item_dropped.connect(UserInterfaceManager.UpdateDisassemblyInfo)
	UserInterfaceManager.disassemblyUI.get_node("DraggableItemSlot").item_dropped.connect(ApplyUnitInventory)
	UserInterfaceManager.UpdateDisassemblyInfo()


func _process(delta):
	if len(selectedUnits) == 1:
		UserInterfaceManager.ToggleUnitUI(true)
		UserInterfaceManager.UpdateUnitBarUI(selectedUnits[0])
		UserInterfaceManager.UpdateInventoryWeight(selectedUnits[0])
		UserInterfaceManager.UpdateInformationUI(selectedUnits[0])
	else:
		UserInterfaceManager.CloseInteractionWindows()
		UserInterfaceManager.ToggleUnitUI(false)
		UserInterfaceManager.inventoryUI.visible = false
		UserInterfaceManager.informationUI.visible = false
		UserInterfaceManager.craftingStationUI.visible = false
	
	if lockOn:
		if len(selectedUnits) > 0:
			Camera.cam.position = selectedUnits[0].position
	

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
					if not selectedUnits[0].update_unit_inventory_ui.is_connected(UpdateUnitInventoryUI):
						selectedUnits[0].update_unit_inventory_ui.connect(UpdateUnitInventoryUI)
					if not selectedUnits[0].update_interaction_ui.is_connected(UpdateInteractionUI):
						selectedUnits[0].update_interaction_ui.connect(UpdateInteractionUI)
				
					# update ui to show newly selected unit
					#UserInterfaceManager.UpdateUnitInfoPanel(selectedUnits[0])
					UserInterfaceManager.informationUI.visible = selectedUnits[0].isInfoOpen
					UserInterfaceManager.inventoryUI.visible = selectedUnits[0].isInventoryOpen
					UpdateUnitInventoryUI()
					UpdateInteractionUI()
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
					unit.interactionObject = null
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
					
			if event.keycode == KEY_Y:
				lockOn = not lockOn
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
	
	

# update all UI related to unit information
func UpdateUnitUI():
	if len(selectedUnits) > 0:
		UserInterfaceManager.UpdateInventoryUI(selectedUnits[0])


func UpdateUnitInventoryUI():
	if len(selectedUnits) > 0:
		UserInterfaceManager.UpdateInventoryUI(selectedUnits[0])

	UserInterfaceManager.UpdateInventoryWeight(selectedUnits[0])
	

# makes interaction ui visible
func UpdateInteractionUI():
	UserInterfaceManager.UpdateInteractionUI(selectedUnits[0])
	
	
func ApplyUnitInventory():
	selectedUnits[0].inventory = UserInterfaceManager.ReadInventoryGrid()
	var equipments = UserInterfaceManager.ReadEquipmentSlots()
	selectedUnits[0].headSlot = equipments.Head
	selectedUnits[0].bodySlot = equipments.Body
	selectedUnits[0].primarySlot = equipments.Primary
	
	if selectedUnits[0].interactionObject != null and selectedUnits[0].interactionObject is ItemContainer:
		selectedUnits[0].interactionObject.contents = UserInterfaceManager.ReadContainerGrid()
	
	selectedUnits[0].UpdateStats()
	

func SelectSingleUnit(unit):
	Game.SetSelectionUI(false)
	selectedUnits = []
	selectedUnits.append(unit)
	unit.ShowSelectionUI()
	
	if not selectedUnits[0].update_unit_ui.is_connected(UpdateUnitUI):
		selectedUnits[0].update_unit_ui.connect(UpdateUnitUI)
	if not selectedUnits[0].update_unit_inventory_ui.is_connected(UpdateUnitInventoryUI):
		selectedUnits[0].update_unit_inventory_ui.connect(UpdateUnitInventoryUI)
	if not selectedUnits[0].update_interaction_ui.is_connected(UpdateInteractionUI):
		selectedUnits[0].update_interaction_ui.connect(UpdateInteractionUI)
		
	UserInterfaceManager.inventoryUI.visible = unit.isInventoryOpen
	UserInterfaceManager.informationUI.visible = unit.isInfoOpen
	UserInterfaceManager.UpdateInventoryUI(selectedUnits[0])
	UserInterfaceManager.UpdateInteractionUI(selectedUnits[0])


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


func _on_drop_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	var newItem = placedItem.instantiate()
	var removed = selectedUnits[0].RemoveByIndex(selectedItemIndex)
	newItem.itemType = removed.type
	newItem.itemID = removed.data.ID
	newItem.item = removed
	newItem.position = selectedUnits[0].position
	add_sibling(newItem)
	
	selectedUnits[0].UpdateStats()


func _on_consume_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	var data = selectedUnits[0].inventory[selectedItemIndex].data
	
	Spaceship.ConsumeAmmo( -data.ammo)
	Spaceship.ConsumeFood( -data.food)
	Spaceship.ConsumeComponents( -data.components)
	
	selectedUnits[0].HealHealth(data.heal * selectedUnits[0].maxHealth)
	
	selectedUnits[0].RemoveByIndex(selectedItemIndex)
	

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


func _on_crafting_menu_button_pressed(extra_arg_0):
	UserInterfaceManager.UpdateCraftingUI(extra_arg_0)


func _on_print_button_pressed():
	# get selected type and selected id
	var type = UserInterfaceManager.craftingStationUIType
	var id = UserInterfaceManager.craftingStationUI.get_node("ItemList").get_selected_items()[0]
	
	# check if enough components
	if Spaceship.ConsumeComponents(DataManager.resources[type][id].componentValue):
		print("made item!")
		selectedUnits[0].AddItemByIndex(type, id)
		UserInterfaceManager.UpdateInventoryUI(selectedUnits[0])
	else:
		print("Not enough components!")


# update item info in crafting menu
func _on_craft_menu_item_list_item_selected(index):
	UserInterfaceManager.UpdateCraftingItemInfo()


func _on_inventory_button_pressed():
	if selectedUnits.size() > 0:
		if UserInterfaceManager.inventoryUI.visible == false:
			UserInterfaceManager.UpdateInventoryUI(selectedUnits[0])
			UserInterfaceManager.inventoryUI.visible = true
		else:
			UserInterfaceManager.inventoryUI.visible = false
		
		selectedUnits[0].isInventoryOpen = not selectedUnits[0].isInventoryOpen


func _on_disassemble_button_pressed():
	# toggle ui visibility
	selectedUnits[0].isInteractionOn = true
	if selectedUnits.size() > 0:
		if UserInterfaceManager.disassemblyUI.visible == false:
			UserInterfaceManager.UpdateDisassemblyInfo()
		else:
			UserInterfaceManager.disassemblyUI.visible = false
			
	var slotItem = UserInterfaceManager.disassemblyUI.get_node("DraggableItemSlot")
	if slotItem.get_child_count() > 0:
		slotItem = slotItem.get_child(0)
	else:
		UserInterfaceManager.UpdateDisassemblyInfo()
		return
	
	var amount = slotItem.item.data.componentValue * randf_range(0.4, 0.8)
	Spaceship.ConsumeComponents(-amount)
	slotItem.queue_free()
	UserInterfaceManager.UpdateDisassemblyInfo()
	


func _on_information_button_pressed():
	if selectedUnits[0].isInfoOpen:
		UserInterfaceManager.informationUI.visible = false
	else:
		UserInterfaceManager.UpdateInformationUI(selectedUnits[0])
		UserInterfaceManager.informationUI.visible = true
		
	selectedUnits[0].isInfoOpen = not selectedUnits[0].isInfoOpen


func _on_info_closebutton_pressed():
	UserInterfaceManager.informationUI.visible = false
	selectedUnits[0].isInfoOpen = false


func _on_interaction_button_pressed():
	var obj = selectedUnits[0].interactionObject
	if obj == null:
		UserInterfaceManager.CloseInteractionWindows()
	else:
		if obj is ItemContainer:
			UserInterfaceManager.containerUI.visible = not UserInterfaceManager.containerUI.visible
			selectedUnits[0].isInteractionOpen = UserInterfaceManager.containerUI.visible
		if obj is Disassembly:
			UserInterfaceManager.disassemblyUI.visible = not UserInterfaceManager.disassemblyUI.visible
			selectedUnits[0].isInteractionOpen = UserInterfaceManager.disassemblyUI.visible
		if obj is CraftingStation:
			UserInterfaceManager.craftingStationUI.visible = not UserInterfaceManager.craftingStationUI.visible
			selectedUnits[0].isInteractionOpen = UserInterfaceManager.craftingStationUI.visible
			

func _on_container_closebutton_pressed():
	UserInterfaceManager.containerUI.visible = false
	selectedUnits[0].isInteractionOpen = false


func _on_inventory_closebutton_pressed():
	UserInterfaceManager.inventoryUI.visible = false
	selectedUnits[0].isInventoryOpen = false


func _on_crafting_station_closebutton_pressed():
	UserInterfaceManager.craftingStationUI.visible = false
	selectedUnits[0].isInteractionOpen = false
