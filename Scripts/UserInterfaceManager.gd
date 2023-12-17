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

static var inventoryContextMenu

static var unitInfoLabel

static var unitEquipmentLabel

static var foodStockLabel

static var ammoStockLabel

static var componentsStockLabel

static var containerUI

static var spaceshipOverviewUI

static var spaceshipOverviewPanel
static var overviewMarker = preload("res://Scenes/overview_marker.tscn")

static var craftingStationUI
static var craftingStationUIType: int = 0

static var inventoryUI
static var inventoryGrid
static var draggableItem = preload("res://Scenes/draggable_item.tscn")

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
	itemList = $UnitUI/InfoPanel/ItemList
	inventoryContextMenu = $UnitUI/InfoPanel/ContextMenu
	infoPanel = $UnitUI/InfoPanel
	infoPanelButton = $UnitUI/InformationButton
	inventoryPanelButton = $UnitUI/InventoryButton
	equipmentPanelButton = $UnitUI/EquipmentButton
	unitInfoLabel = infoPanel.get_node("UnitInfoLabel")
	unitEquipmentLabel = infoPanel.get_node("UnitEquipmentLabel")
	foodStockLabel = $ResourcesUI/FoodStockLabel
	ammoStockLabel = $ResourcesUI/AmmoStockLabel
	componentsStockLabel = $ResourcesUI/ComponentsStockLabel
	containerUI = $UnitUI/ContainerUI
	spaceshipOverviewUI = $SpaceshipOverviewUI
	spaceshipOverviewPanel = $SpaceshipOverviewUI/SpaceshipOverviewPanel
	craftingStationUI = $CraftingStationUI
	inventoryUI = $InventoryUI
	inventoryGrid = inventoryUI.get_node("InventoryGrid")


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


static func UpdateUnitInfoUI(unit):
	unitInfoLabel.text = str(unit)
	
	
static func UpdateUnitEquipmentInfoUI(unit):
	unitEquipmentLabel.text = unit.PrintEquipmentStatus()
	
	
static func UpdateUnitInventory(unit):
	var inventory = unit.inventory
	
	itemList.clear()
	
	for i in len(inventory):
		var item = inventory[i]
		var index = itemList.add_item(item.data.name)
		itemList.set_item_tooltip(index, str(item))
	
	for i in unit.equipmentSlots:
		if i >= 0:
			var text = itemList.get_item_text(i)
			itemList.set_item_text(i, text + " (E)")
	
	# update container ui
	if unit.interactionContainer != null:
		containerUI.visible = true
		
		var containerList = containerUI.get_node("ItemList")
		
		containerList.clear()
		
		for i in len(unit.interactionContainer.contents):
			var item = unit.interactionContainer.contents[i]
			var index = containerList.add_item(item.data.name)
			containerList.set_item_tooltip(index, str(item))
			
		var container = unit.interactionContainer
		containerUI.get_node("Label").text = "Container " + str(container.weight) + "/" + str(container.capacity)


# toggles the entire unit ui element
static func ToggleUnitUI(val):
	unitUI.visible = val


# updates the unit info panel. switches to right panel and updates its data
static func UpdateUnitInfoPanel(unit):
	infoPanel.visible = true
	itemList.visible = false
	inventoryContextMenu.visible = false
	unitInfoLabel.visible = false
	unitEquipmentLabel.visible = false
	containerUI.visible = false
	
	# update inventory weight
	inventoryPanelButton.text = "Inventory " + str(unit.inventoryWeight) + "/" + str(unit.inventoryCapacity)
	
	if infoPanelButton.button_pressed:
		UpdateUnitInfoUI(unit)
		unitInfoLabel.visible = true
	elif inventoryPanelButton.button_pressed:
		itemList.visible = true
		UpdateUnitInventory(unit)
	elif equipmentPanelButton.button_pressed:
		UpdateUnitEquipmentInfoUI(unit)
		unitEquipmentLabel.visible = true
	else:
		infoPanel.visible = false
		
		
static func CheckContextMenuVisibility():
	if itemList.is_anything_selected():
		inventoryContextMenu.visible = true
	else:
		inventoryContextMenu.visible = false
		
		
static func ModifyContextMenuByItem(index, unit):
	var item = unit.inventory[index]
	
	# show different buttons if item is consumable
	if item.type == 4:
		inventoryContextMenu.get_node("EquipButton").visible = false
		inventoryContextMenu.get_node("ConsumeButton").visible = true
	else:
		# check if selected is equipped or not
		if index in unit.equipmentSlots:
			inventoryContextMenu.get_node("EquipButton").visible = false
			inventoryContextMenu.get_node("UnequipButton").visible = true
		else:
			inventoryContextMenu.get_node("EquipButton").visible = true
			inventoryContextMenu.get_node("UnequipButton").visible = false
			
		inventoryContextMenu.get_node("ConsumeButton").visible = false


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


static func GetMouseOnItemSlot():
	for item in inventoryUI.get_node("InventoryGrid").get_children():
		if item.mouseOnThis:
			return item
	
	for item in inventoryUI.get_node("InventoryGrid").get_children():
		item.mouseOnThis = false
		
	return null


# makes draggable items based on selected unit inventory
# assumes that the number of items in an inventory does not go over 24 items
static func PopulateInventoryGrid(inventory):
	inventoryUI.visible = true
	for i in range(24):
		var slot: Node = inventoryGrid.get_child(i)
		# if slot has a draggable item, remove it
		for j in range(slot.get_child_count()):
			slot.get_child(j).queue_free()
		
		if i < len(inventory):
			var newDraggable: DraggableItem = draggableItem.instantiate()
			newDraggable.item = inventory[i]
			newDraggable.get_node("TEMP_itemName").text = inventory[i].data.name
			slot.add_child(newDraggable)
			newDraggable.position = Vector2.ZERO


# modifies selected unit's items based the inventory grids current state
static func ReadInventoryGrid():
	pass


func _on_inventory_ui_closebutton_pressed():
	inventoryUI.visible = false
