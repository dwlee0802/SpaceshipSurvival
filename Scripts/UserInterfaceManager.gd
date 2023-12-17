extends Node

class_name UserInterfaceManager

static var travelProgressUI

static var spaceshipStatusUI

static var healthBar

static var oxygenBar

static var temperatureBar

static var sleepBar

static var nutritionBar

static var expBar

static var BAR_LENGTH = 200
static var EXP_BAR_LENGTH = 320

static var unitUI

static var infoPanel

static var infoPanelButton
static var inventoryPanelButton
static var equipmentPanelButton

static var itemList: ItemList

static var unitInfoLabel

static var unitEquipmentLabel

static var foodStockLabel

static var ammoStockLabel

static var componentsStockLabel

static var spaceshipOverviewUI

static var spaceshipOverviewPanel
static var overviewMarker = preload("res://Scenes/overview_marker.tscn")

static var craftingStationUI
static var craftingStationUIType: int = 0

static var inventoryUI
static var inventoryGrid
static var draggableItem = preload("res://Scenes/draggable_item.tscn")

static var containerUI
static var containerGrid

static var disassemblyUI

static var informationUI
static var informationUIHealth
static var informationUICombat
static var informationUIMisc


# Called when the node enters the scene tree for the first time.
func _ready():
	travelProgressUI = $TravelProgressUI
	spaceshipStatusUI = $SpaceshipStatusUI
	healthBar = $UnitUI/HealthBar/TextureRect
	oxygenBar = $UnitUI/OxygenBar/TextureRect
	temperatureBar = $UnitUI/TemperatureBar/TextureRect
	sleepBar = $UnitUI/SleepBar/TextureRect
	nutritionBar = $UnitUI/NutritionBar/TextureRect
	expBar = $UnitUI/ExperienceBar/TextureRect
	unitUI = $UnitUI
	infoPanelButton = $UnitUI/InformationButton
	inventoryPanelButton = $UnitUI/InventoryButton
	foodStockLabel = $ResourcesUI/FoodStockLabel
	ammoStockLabel = $ResourcesUI/AmmoStockLabel
	componentsStockLabel = $ResourcesUI/ComponentsStockLabel
	spaceshipOverviewUI = $SpaceshipOverviewUI
	spaceshipOverviewPanel = $SpaceshipOverviewUI/SpaceshipOverviewPanel
	craftingStationUI = $CraftingStationUI
	
	inventoryUI = $InventoryUI
	inventoryGrid = inventoryUI.get_node("InventoryGrid")
	containerUI = $ContainerUI
	containerGrid = containerUI.get_node("ContainerGrid")
	
	disassemblyUI = $DisassemblyUI
	
	informationUI = $InformationUI
	informationUIHealth = $InformationUI/HealthStats
	informationUICombat = $InformationUI/CombatStats
	informationUIMisc = $InformationUI/MiscStats
	

# change scale x of progress bar based on progress
static func UpdateTravelProgressUI(cur, maxVal):
	var maxSize = travelProgressUI.get_node("Background").size.x
	
	travelProgressUI.get_node("ProgressBar").size.x = maxSize * cur / maxVal
	travelProgressUI.get_node("SpaceshipIcon").position.x = maxSize * cur / maxVal - 2
	
	travelProgressUI.get_node("SpaceshipIcon/ProgressPercentLabel").text = str(int(float(cur)/maxVal * 100)) + "%"


# change ship status UI info
static func UpdateSpaceshipStatusUI(oxygen, temp):
	var oxygenLabel = spaceshipStatusUI.get_node("OxygenLevel/Label")
	oxygenLabel.text = str(oxygen) + "%"
	if oxygen < 50:
		oxygenLabel.self_modulate = Color.RED
	else:
		oxygenLabel.self_modulate = Color.WHITE
		
	spaceshipStatusUI.get_node("TemperatureLevel/Label").text = str(temp) + "C"
	
	
static func UpdateUnitBarUI(unit: Survivor):
	healthBar.size.x = unit.health / unit.maxHealth * BAR_LENGTH
	oxygenBar.size.x = unit.oxygen / 100 * BAR_LENGTH
	temperatureBar.size.x = unit.bodyTemperature / 50 * BAR_LENGTH
	sleepBar.size.x = unit.sleep / 600 * BAR_LENGTH
	nutritionBar.size.x = unit.nutrition / 100 * BAR_LENGTH
	expBar.size.x = float(unit.experiencePoints) / unit.requiredEXP * EXP_BAR_LENGTH
	

# toggles the entire unit ui element
static func ToggleUnitUI(val):
	unitUI.visible = val


static func UpdateAmmoStockLabel(amount):
	ammoStockLabel.text = "Ammo: " + str(amount) + "/" + str(Spaceship.maxAmmoStock)
	
	
static func UpdateFoodStockLabel(amount):
	foodStockLabel.text = "Food: " + str(amount) + "/" + str(Spaceship.maxFoodStock)
	
	
static func UpdateComponentStockLabel(amount):
	componentsStockLabel.text = "Components: " + str(amount) + "/" + str(Spaceship.maxComponentStock)
	
	
static func UpdateSpaceshipOverviewUI(val = true):
	if val:
		spaceshipOverviewUI.visible = true
		spaceshipOverviewUI.get_node("ModuleStatus").text = Game.spaceship.PrintModuleStatus()
	else:
		spaceshipOverviewUI.visible = false


static func UpdateSpaceshipOverviewText():
	spaceshipOverviewUI.get_node("ModuleStatus").text = Game.spaceship.PrintModuleStatus()


# instantiate a marker and return it to the caller
static func MakeMarkerOnSpaceshipOverview():
	var newMarker = overviewMarker.instantiate()
	spaceshipOverviewPanel.add_child(newMarker)
	return newMarker
	
	
static func UpdateCraftingUI(type):
	craftingStationUIType = type
	var optionList: ItemList = craftingStationUI.get_node("ItemList")
	optionList.clear()
	var data = DataManager.resources[type]
	for item in data:
		optionList.add_item(item.name)


static func UpdateCraftingItemInfo():
	var selectedIndex = craftingStationUI.get_node("ItemList").get_selected_items()[0]
	var output = ""
	var data =  DataManager.resources[craftingStationUIType][selectedIndex]
	output += data.name + "\n"
	output += "Cost: " + str(data.componentValue) + " components\n"
	craftingStationUI.get_node("ItemInfo").text = output


static func UpdateInventoryUI(unit: Survivor):	
	UpdateInventoryWeight(unit)
	inventoryUI.visible = true
	
	PopulateInventoryGrid(unit)
	
	if unit.interactionContainer != null:
		# populate container UI
		UpdateContainerUI(unit.interactionContainer)


static func UpdateContainerUI(container: ItemContainer):
	containerUI.visible = true
	PopulateContainerGrid(container)
	

static func UpdateInventoryWeight(unit: Survivor):
	# update inventory weight
	inventoryPanelButton.text = "Inventory " + str(unit.inventoryWeight) + "/" + str(unit.inventoryCapacity)
	
	
# makes draggable items based on selected unit inventory
# assumes that the number of items in an inventory does not go over 24 items
static func PopulateInventoryGrid(unit: Survivor):
	var inventory = unit.inventory
	
	# remove stuff from equipment slots
	var equipSlot = inventoryUI.get_node("BodySlot/DraggableItem")
	for j in range(equipSlot.get_child_count()):
		equipSlot.get_child(j).queue_free()
		
	equipSlot = inventoryUI.get_node("HeadSlot/DraggableItem")
	for j in range(equipSlot.get_child_count()):
		equipSlot.get_child(j).queue_free()
		
	equipSlot = inventoryUI.get_node("PrimarySlot/DraggableItem")
	for j in range(equipSlot.get_child_count()):
		equipSlot.get_child(j).queue_free()
			
	for i in range(24):
		var slot: Node = inventoryGrid.get_child(i)
		# if slot has a draggable item, remove it
		for j in range(slot.get_child_count()):
			slot.get_child(j).queue_free()
			
			
		if i < len(inventory):
			var newDraggable: DraggableItem = draggableItem.instantiate()
			# this slot is empty
			if inventory[i] == null:
				continue
				
			newDraggable.item = inventory[i]
			newDraggable.get_node("TEMP_itemName").text = inventory[i].data.name
					
			slot.add_child(newDraggable)
			newDraggable.position = Vector2.ZERO
	
	# make items at equipment slots
	var slot = inventoryUI.get_node("HeadSlot/DraggableItem")
	if unit.headSlot != null:
		var newDraggable: DraggableItem = draggableItem.instantiate()
		newDraggable.item = unit.headSlot
		newDraggable.get_node("TEMP_itemName").text = unit.headSlot.data.name
		slot.add_child(newDraggable)
		newDraggable.position = Vector2.ZERO
		
	slot = inventoryUI.get_node("BodySlot/DraggableItem")
	if unit.bodySlot != null:
		var newDraggable: DraggableItem = draggableItem.instantiate()
		newDraggable.item = unit.bodySlot
		newDraggable.get_node("TEMP_itemName").text = unit.bodySlot.data.name
		slot.add_child(newDraggable)
		newDraggable.position = Vector2.ZERO
		
	slot = inventoryUI.get_node("PrimarySlot/DraggableItem")
	if unit.primarySlot != null:
		var newDraggable: DraggableItem = draggableItem.instantiate()
		newDraggable.item = unit.primarySlot
		newDraggable.get_node("TEMP_itemName").text = unit.primarySlot.data.name
		slot.add_child(newDraggable)
		newDraggable.position = Vector2.ZERO


static func PopulateContainerGrid(container: ItemContainer):
	var inventory = container.contents
			
	for i in range(24):
		var slot: Node = containerGrid.get_child(i)
		# if slot has a draggable item, remove it
		for j in range(slot.get_child_count()):
			slot.get_child(j).queue_free()
			
		if i < len(inventory):
			var newDraggable: DraggableItem = draggableItem.instantiate()
			# this slot is empty
			if inventory[i] == null:
				continue
				
			newDraggable.item = inventory[i]
			newDraggable.get_node("TEMP_itemName").text = inventory[i].data.name
			
			slot.add_child(newDraggable)
			newDraggable.position = Vector2.ZERO


# return a list of items in the inventory grid
static func ReadInventoryGrid():
	var outputList = []
	outputList.resize(Survivor.MAX_INVENTORY_COUNT)
	for i in range(len(outputList)):
		var slot = inventoryGrid.get_child(i)
		if slot.get_child_count() > 0:
			outputList[i] = slot.get_child(0).item
		else:
			outputList[i] = null
	
	return outputList


# returns a dictionary that has key: inventory slot type, value: inventory object
static func ReadEquipmentSlots():
	var outputDict = {}
	var slot = inventoryUI.get_node("HeadSlot/DraggableItem")
	if slot.get_child_count() > 0:
		outputDict["Head"] = slot.get_child(0).item
	else:
		outputDict["Head"] = null
		
	slot = inventoryUI.get_node("BodySlot/DraggableItem")
	if slot.get_child_count() > 0:
		outputDict["Body"] = slot.get_child(0).item
	else:
		outputDict["Body"] = null
		
	slot = inventoryUI.get_node("PrimarySlot/DraggableItem")
	if slot.get_child_count() > 0:
		outputDict["Primary"] = slot.get_child(0).item
	else:
		outputDict["Primary"] = null
	
	return outputDict
	

static func ReadContainerGrid():
	var outputList = []
	outputList.resize(Survivor.MAX_INVENTORY_COUNT)
	for i in range(len(outputList)):
		var slot = containerGrid.get_child(i)
		if slot.get_child_count() > 0:
			outputList[i] = slot.get_child(0).item
		else:
			outputList[i] = null
	
	return outputList


static func UpdateDisassemblyInfo():
	var label = disassemblyUI.get_node("DisassemblyInfoLabel")
	if disassemblyUI.get_node("DraggableItemSlot").get_child_count() == 0:
		label.text = "Place item in slot to disassemble"
		return
		
	var item: Item = disassemblyUI.get_node("DraggableItemSlot").get_child(0).item
	label.text = "Item Components Value: " + str(item.data.componentValue) + "\nExpected output: " + str(item.data.componentValue * 0.4) + " - " + str(item.data.componentValue * 0.8)
	

static func UpdateInformationUI(unit: Survivor):
	informationUIHealth.text = unit.PrintHealthStats()
	informationUICombat.text = unit.PrintCombatStats()
	informationUIMisc.text = unit.PrintMiscStats()
	
	
func _on_inventory_ui_closebutton_pressed():
	inventoryUI.visible = false


func _on_container_ui_closebutton_pressed():
	containerUI.visible = false


func _on_disassembly_closebutton_pressed():
	disassemblyUI.visible = false
