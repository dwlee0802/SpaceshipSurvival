extends Node2D
class_name InputManager

static var selectedUnits = []

var placedItem = preload("res://Scenes/placed_item.tscn")

var dragging: bool = false
var drag_start = Vector2.ZERO

var lockOn: bool = false

@onready var selectionBox = $SelectionBox

static var InputManagerInstance

static var waitingForSkillLocation: bool = false


func _ready():
	InputManagerInstance = self
	
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
		#UserInterfaceManager.UpdateEquipmentUI(selectedUnits[0].primarySlot)
		var callable = Callable(UserInterfaceManager, "UpdateEquipmentUI")
		callable.call(selectedUnits[0].primarySlot)
		callable = Callable(UserInterfaceManager, "UpdateSkillButtons")
		callable.call(selectedUnits[0])
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
					
					if Input.is_key_pressed(KEY_SHIFT):
						unit.running = true
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
			
					if Input.is_key_pressed(KEY_SHIFT):
						unit.running = true
				
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
				if len(Game.survivors) >= 3:
					SelectSingleUnit(Game.survivors[2])
			if event.keycode == KEY_4:
				if len(Game.survivors) >= 4:
					SelectSingleUnit(Game.survivors[3])
			
			# show spaceship overview UI
			if event.keycode == KEY_TAB:
				UserInterfaceManager.UpdateSpaceshipOverviewUI()
				
			# pause button
			if event.keycode == KEY_SPACE:
				if Engine.time_scale == 0.5:
					Engine.time_scale = 1
				else:
					Engine.time_scale = 0.5
					
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
	if selectedUnits.size() > 0:
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
	

static func UseInventoryItem(draggable):
	var unit: Survivor = selectedUnits[0]
	
	# draggable is in inventory
	if draggable.get_parent() in UserInterfaceManager.inventoryGrid.get_children():
		# remove draggable
		# apply whatever effect
		var item: Item = draggable.item
		if item.data.type == ItemType.Consumable:
			# Medkit
			if item.data.ID == 0:
				unit.HealHealth(item.data.amount)
			# Oxygen Inhaler
			if item.data.ID == 1:
				if unit.oxygen + item.data.amount > 100:
					unit.oxygen = 100
				else:
					unit.oxygen += item.data.amount
		# equip gear
		if item.data.type == ItemType.Head:
			# check if slot is empty
			var slot = UserInterfaceManager.inventoryUI.get_node("HeadSlot/DraggableItem")
			if slot.get_child_count() == 0:
				# slot is empty. Just equip
				unit.EquipNewItem(item, SlotType.Head)
				draggable.reparent(slot)
			else:
				# swap items
				var prevItem = slot.get_child(0)
				prevItem.reparent(draggable.get_parent())
				prevItem.position = Vector2.ZERO
				draggable.reparent(slot)
				draggable.position = Vector2.ZERO
				unit.EquipNewItem(item, SlotType.Head)
		
		if item.data.type == ItemType.Body:
			# check if slot is empty
			var slot = UserInterfaceManager.inventoryUI.get_node("BodySlot/DraggableItem")
			if slot.get_child_count() == 0:
				# slot is empty. Just equip
				unit.EquipNewItem(item, SlotType.Body)
				draggable.reparent(slot)
			else:
				# swap items
				var prevItem = slot.get_child(0)
				prevItem.reparent(draggable.get_parent())
				prevItem.position = Vector2.ZERO
				draggable.reparent(slot)
				draggable.position = Vector2.ZERO
				unit.EquipNewItem(item, SlotType.Body)
				
		if item.data.type == ItemType.Melee or item.data.type == ItemType.Ranged:
			# check if slot is empty
			var slot = UserInterfaceManager.inventoryUI.get_node("PrimarySlot/DraggableItem")
			if slot.get_child_count() == 0:
				# slot is empty. Just equip
				unit.EquipNewItem(item, SlotType.Primary)
				draggable.reparent(slot)
			else:
				# swap items
				var prevItem = slot.get_child(0)
				prevItem.reparent(draggable.get_parent())
				prevItem.position = Vector2.ZERO
				draggable.reparent(slot)
				draggable.position = Vector2.ZERO
				unit.EquipNewItem(item, SlotType.Primary)
		
		draggable.queue_free()
		unit.inventory = UserInterfaceManager.ReadInventoryGrid()
		var index = unit.inventory.find(item)
		if index > 0:
			unit.inventory.remove_at(index)
		var equipmentDict = UserInterfaceManager.ReadEquipmentSlots()
		unit.headSlot = equipmentDict.Head
		unit.bodySlot = equipmentDict.Body
		unit.primarySlot = equipmentDict.Primary
		unit.UpdateStats()
	
	# draggable is in container
	if draggable.get_parent() in UserInterfaceManager.containerGrid.get_children():
		# move item to inventory
		var item: Item = draggable.item
		unit.AddItem(draggable.item)
		draggable.queue_free()
		if unit.interactionObject is ItemContainer:
			unit.interactionObject.contents.remove_at(unit.interactionObject.contents.find(item))
	
	UserInterfaceManager.UpdateInventoryUI(unit)
	
	
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
	var slotItem = UserInterfaceManager.disassemblyUI.get_node("DraggableItemSlot")
	if slotItem.get_child_count() > 0:
		slotItem = slotItem.get_child(0)
	else:
		UserInterfaceManager.UpdateDisassemblyInfo()
		return
	
	var amount = slotItem.item.data.componentValue * randf_range(0.2, 0.6)
	Spaceship.ConsumeComponents(-amount)
	slotItem.queue_free()
	UserInterfaceManager.UpdateDisassemblyInfo()
	


func _on_information_button_pressed():
	if selectedUnits[0].isInfoOpen:
		UserInterfaceManager.inforyUI/InventoryGrid" instance=ExtResource("21_8pb3y")]
layout_mode = 2

[node name="DraggableItemSlot22" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("21_8pb3y")]
layout_mode = 2

[node name="DraggableItemSlot23" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("21_8pb3y")]
layout_mode = 2

[node name="DraggableItemSlot24" parent="Camera/Canvas/InventoryUI/InventoryGrid" instance=ExtResource("21_8pb3y")]
layout_mode = 2

[node name="HeadSlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 10.0
offset_top = 40.0
offset_right = 84.0
offset_bottom = 63.0
text = "Head Slot"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/HeadSlot" instance=ExtResource("21_8pb3y")]
layout_mode = 1
offset_left = 20.0
offset_top = 30.0
offset_right = -4.0
offset_bottom = 57.0
type = 0

[node name="BodySlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 10.0
offset_top = 120.0
offset_right = 84.0
offset_bottom = 143.0
text = "Body Slot"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/BodySlot" instance=ExtResource("21_8pb3y")]
layout_mode = 1
offset_left = 20.0
offset_top = 30.0
offset_right = -4.0
offset_bottom = 57.0
type = 1

[node name="PrimarySlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 10.0
offset_top = 200.0
offset_right = 105.0
offset_bottom = 223.0
text = "Primary Slot"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/PrimarySlot" instance=ExtResource("21_8pb3y")]
layout_mode = 1
offset_left = 20.0
offset_top = 30.0
offset_right = -25.0
offset_bottom = 57.0
type = 2

[node name="DropSlot" type="Label" parent="Camera/Canvas/InventoryUI"]
layout_mode = 0
offset_left = 472.0
offset_top = 206.0
offset_right = 551.0
offset_bottom = 229.0
text = "Drop Item"

[node name="DraggableItem" parent="Camera/Canvas/InventoryUI/DropSlot" instance=ExtResource("21_8pb3y")]
layout_mode = 1
offset_left = 15.0
offset_top = 24.0
offset_right = -14.0
offset_bottom = 51.0
script = ExtResource("22_tgjxd")

[node name="LevelUpEffect" type="Polygon2D" parent="Camera/Canvas/InventoryUI/DropSlot"]
position = Vector2(40, 30)
rotation = 3.14159
scale = Vector2(0.503803, 0.469087)
color = Color(0.447059, 0, 0.054902, 0.47451)
polygon = PackedVector2Array(-22, 0, 22, 0, 22, -55, 40, -55