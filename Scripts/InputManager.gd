extends Node2D
class_name InputManager

var placedItem = preload("res://Scenes/placed_item.tscn")

static var InputManagerInstance

var currentSkillObject = null


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
	UserInterfaceManager.ToggleUnitUI(true)
	UserInterfaceManager.UpdateUnitBarUI(Game.survivor)
	UserInterfaceManager.UpdateInventoryWeight(Game.survivor)
	UserInterfaceManager.UpdateInformationUI(Game.survivor)
	#UserInterfaceManager.UpdateEquipmentUI(Game.survivor.primarySlot)
	var callable = Callable(UserInterfaceManager, "UpdateEquipmentUI")
	callable.call(Game.survivor.primarySlot)
	callable = Callable(UserInterfaceManager, "UpdateSkillButtons")
	callable.call(Game.survivor)
	
	# disable skill buttons if they are on cooldown
	if Game.survivor.skillReady_1:
		UserInterfaceManager.skillButton_1.disabled = false
	else:
		UserInterfaceManager.skillButton_1.disabled = true	
	UserInterfaceManager.skillButton_cd_1.size.y = Game.survivor.skillCooldownTimer1.time_left / Game.survivor.skillCooldownTimer1.wait_time * 70
	if Game.survivor.skillReady_2:
		UserInterfaceManager.skillButton_2.disabled = false
	else:
		UserInterfaceManager.skillButton_2.disabled = true
	UserInterfaceManager.skillButton_cd_2.size.y = Game.survivor.skillCooldownTimer2.time_left / Game.survivor.skillCooldownTimer2.wait_time * 70


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			# show spaceship overview UI
			if event.keycode == KEY_TAB:
				UserInterfaceManager.UpdateSpaceshipOverviewUI()
				
			# pause button
			if event.keycode == KEY_F1:
				Engine.time_scale = 0.5
			if event.keycode == KEY_F2:
				Engine.time_scale = 1
			if event.keycode == KEY_F3:
				Engine.time_scale = 2
		else:
			# show spaceship overview UI
			if event.keycode == KEY_TAB:
				UserInterfaceManager.UpdateSpaceshipOverviewUI(false)
	

func _on_equip_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	
	var itemType = Game.survivor.inventory[selectedItemIndex].type
	
	var slotType
	
	# equip weapon
	if itemType == ItemType.Melee or itemType == ItemType.Ranged:
		slotType = SlotType.Primary
	
	# equip armor
	if itemType == ItemType.Head:
		slotType = SlotType.Head
	if itemType == ItemType.Body:
		slotType = SlotType.Body
	
	Game.survivor.EquipItemFromInventory(selectedItemIndex, slotType)
	Game.survivor.UpdateStats()
	
	

# update all UI related to unit information
func UpdateUnitUI():
	UserInterfaceManager.UpdateInventoryUI(Game.survivor)


func UpdateUnitInventoryUI():
	UserInterfaceManager.UpdateInventoryUI(Game.survivor)
	UserInterfaceManager.UpdateInventoryWeight(Game.survivor)
	

# makes interaction ui visible
func UpdateInteractionUI():
	UserInterfaceManager.UpdateInteractionUI(Game.survivor)
	
	
func ApplyUnitInventory():
	Game.survivor.inventory = UserInterfaceManager.ReadInventoryGrid()
	var equipments = UserInterfaceManager.ReadEquipmentSlots()
	Game.survivor.headSlot = equipments.Head
	Game.survivor.bodySlot = equipments.Body
	Game.survivor.primarySlot = equipments.Primary
	
	if Game.survivor.interactionObject != null and Game.survivor.interactionObject is ItemContainer:
		Game.survivor.interactionObject.contents = UserInterfaceManager.ReadContainerGrid()
	
	Game.survivor.UpdateStats()
	

static func UseInventoryItem(draggable):
	var unit: Survivor = Game.survivor
	
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
			# Coffee Can
			if item.data.ID == 2:
				if unit.sleep + item.data.amount > 100:
					unit.sleep = 100
				else:
					unit.sleep += item.data.amount
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
		if index >= 0:
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
	var itemType = Game.survivor.inventory[selectedItemIndex].type
	var slotType
	
	# equip weapon
	if itemType == ItemType.Melee or itemType == ItemType.Ranged:
		slotType = SlotType.Primary
	
	# equip armor
	if itemType == ItemType.Head:
		slotType = SlotType.Head
	if itemType == ItemType.Body:
		slotType = SlotType.Body

	Game.survivor.equipmentSlots[slotType] = -1
	
	Game.survivor.UpdateStats()


func _on_drop_button_pressed():
	var selectedItemIndex: int = UserInterfaceManager.itemList.get_selected_items()[0]
	var newItem = placedItem.instantiate()
	var removed = Game.survivor.RemoveByIndex(selectedItemIndex)
	newItem.itemType = removed.type
	newItem.itemID = removed.data.ID
	newItem.item = removed
	newItem.position = Game.survivor.position
	add_sibling(newItem)
	
	Game.survivor.UpdateStats()
	

func _on_crafting_menu_button_pressed(extra_arg_0):
	UserInterfaceManager.UpdateCraftingUI(extra_arg_0)


func _on_print_button_pressed():
	# get selected type and selected id
	var type = UserInterfaceManager.craftingStationUIType
	var id = UserInterfaceManager.craftingStationUI.get_node("ItemList").get_selected_items()[0]
	
	# check if enough components
	if Spaceship.ConsumeComponents(DataManager.resources[type][id].componentValue):
		print("made item!")
		Game.survivor.AddItemByIndex(type, id)
		UserInterfaceManager.UpdateInventoryUI(Game.survivor)
	else:
		print("Not enough components!")


# update item info in crafting menu
func _on_craft_menu_item_list_item_selected(index):
	UserInterfaceManager.UpdateCraftingItemInfo()


func _on_inventory_button_pressed():
	if UserInterfaceManager.inventoryUI.visible == false:
		UserInterfaceManager.UpdateInventoryUI(Game.survivor)
		UserInterfaceManager.inventoryUI.visible = true
	else:
		UserInterfaceManager.inventoryUI.visible = false


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
	UserInterfaceManager.UpdateInformationUI(Game.survivor)
	UserInterfaceManager.informationUI.visible = true


func _on_info_closebutton_pressed():
	UserInterfaceManager.informationUI.visible = false


func _on_interaction_button_pressed():
	var obj = Game.survivor.interactionObject
	if obj is ItemContainer:
		UserInterfaceManager.containerUI.visible = true
	elif obj is Disassembly:
		UserInterfaceManager.disassemblyUI.visible = true
	elif obj is CraftingStation:
		UserInterfaceManager.craftingStationUI.visible = true
	elif obj is Portal:
		if obj.timeToFix <= 0 and obj.otherPortal.timeToFix <= 0:
			Game.survivor.global_position = obj.otherPortal.global_position
			obj.otherPortal.Fix(0)
	elif obj is PlacedItem:
		Game.survivor.AddItem(obj.item)
		obj.queue_free()
		UpdateUnitInventoryUI()
	elif obj is SleepAccelerator:
		Game.survivor.StartSleeping(obj.accelerationAmount)
		

func _on_container_closebutton_pressed():
	UserInterfaceManager.containerUI.visible = false


func _on_inventory_closebutton_pressed():
	UserInterfaceManager.inventoryUI.visible = false


func _on_crafting_station_closebutton_pressed():
	UserInterfaceManager.craftingStationUI.visible = false


# use skill
# apply cooldown
func _on_skill_button_pressed(extra_arg_0):
	print(extra_arg_0)
	var skillData: Skill
	if extra_arg_0 == 0:
		skillData = Game.survivor.skillSlot_1
			
	if extra_arg_0 == 1:
		skillData = Game.survivor.skillSlot_2
		
	if extra_arg_0 == 2:
		skillData = Game.survivor.skillSlot_3
			
	if extra_arg_0 == 3:
		skillData = Game.survivor.skillSlot_4
	
	if skillData == null:
		print("Skilldata null!")
		return
	
	# set waiting for projectile target location true
	if skillData is ProjectileSkill:
		if currentSkillObject != null and is_instance_valid(currentSkillObject):
			currentSkillObject.queue_free()
			
		var newAreaEff: AreaEffect = Game.MakeAreaEffect()
		newAreaEff.SetData(skillData)
		newAreaEff.reparent(Game.survivor)
		newAreaEff.skill_used.connect(Game.survivor.ApplySkillCooldown)
		Game.survivor.usingSkill = true
		currentSkillObject = newAreaEff
	if skillData is BuffSkill:
		Game.survivor.ApplyBuff(skillData)
		Game.survivor.ApplySkillCooldown(skillData)
