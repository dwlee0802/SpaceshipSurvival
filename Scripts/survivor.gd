extends "res://Scripts/unit.gd"

class_name Survivor

@export var survivorData: SurvivorData

var endAccuracy: float = 0

@onready var bulletScene = preload("res://Scenes/bullet.tscn")

@onready var attackTimer = $AttackTimer

@onready var armSprite = $ArmSprite
@onready var muzzleFlashSprite = $ArmSprite/MuzzleFlash
@onready var attackPoint = $ArmSprite/AttackPoint

@onready var noAmmoLabel = $NoAmmoLabel

@onready var aimingIndicator = $ArmSprite/AimingIndicator

@onready var attackCooldown: bool = false

@onready var interactionArea = $InteractionArea

# the interaction target this unit is moving towards
var interactionTarget

# the interaction object this unit is currently interacting with
var interactionObject

# Holds the itemIDs that the player has in its inventory
# capped at 24 items
var inventory = []
static var MAX_INVENTORY_COUNT = 24

# Holds the index inside inventory of equipped gear
# 0: Head slot, 1: Body slot, 2: primary weapon slot, 3: secondary weapon slot
# -1 itemID means slot is empty
var equipmentSlots = [-1, -1, -1, -1, -1]
var headSlot: Item
var bodySlot: Item
var primarySlot: Item

# how heavy the items this unit is carrying is
# heavier the load, the slower the unit can move
# if weight exceeds capacity, speed is reduced
var inventoryWeight: int = 0
var inventoryCapacity: int = 20


# unit stats

# oxygen level in body. Starts to lose health when it reaches zero
var oxygen: float = 100

var bodyTemperature: float = 36.5

var nutrition: float = 100

# how strong this person is. Affects melee damage and inventory capacity
# 2 inventory cap for 1 strength
var strength: int = 10

var sleep: float = 20

var isDead: bool = false


# Combat Behavior
var moveAndShoot: bool = true
var fireAtWill: bool = true

# survivors join the player's team by being rescued.
var needsRescue: bool = true

# update unit info ui
# emitted when unit's stats are changed
signal update_unit_ui

# update unit inventory ui
# emitted when unit's inventory is changed
# or when unit is interacting with a placed item or container
signal update_unit_inventory_ui

# update interaction uis
# emitted when unit reaches interaction target
signal update_interaction_ui

@onready var expBar = $ExpBar/ExpBar
var experiencePoints: int = 0
var level: int = 1
# required exp to level up. Increases 50 percent each level
var requiredEXP: int = 500
@onready var levelUpEffect = $LevelUpEffect/AnimationPlayer


# skill related stuff
@export var skillSlot_1: Skill
@export var skillSlot_2: Skill

@onready var skillCooldownTimer1 = $SkillCooldownTimer1
var skillReady_1: bool = true
@onready var skillCooldownTimer2 = $SkillCooldownTimer2
var skillReady_2: bool = true


var push_dir: Vector2 = Vector2(0, 0)
var push_strength: float = 0.0
var push_timer: float = 0.0

@export var rotate_flag: bool = true # Enable body rotation 

var isRunning: bool = false
var attacking: bool = false

var spread: float = 0

# modifies reload time
var reloadSpeed: float = 1
var reloading: bool = false
var magazineCount: int = 0
@onready var reloadTimer = $ReloadTimer
@onready var reloadUI = $ReloadProcess

var usingSkill: bool = false

@onready var meleeAttackArea = $ArmSprite/MeleeAttackArea
@onready var meleeAttackTimer = $MeleeAttackTimer
var meleeCooldown: bool = false


# sound
@onready var audioPlayer: AudioStreamPlayer = $AudioStreamPlayer

# sleeping
var sleeping: bool = false
var sleepingCooldown: bool = false
@onready var sleepingCooldownTimer: Timer = $SleepCooldownTimer
@onready var sleepingParticleEffect = $SleepingParticleEffect
var sleepGainModifier: float = 1


func _ready():
	super._ready()
	inventory.resize(MAX_INVENTORY_COUNT)
	
	overviewMarker.self_modulate = Color.GREEN
	
	LoadSurvivorData()
	
	AddItem(Item.new(4,0))
	UpdateStats()
	
	# start with full health
	health = maxHealth
	
	Reload()
	

# modifies starting stats based on the chosen survivor
func LoadSurvivorData():
	maxHealth = survivorData.maxHealth
	primarySlot = Item.new(survivorData.startingPrimary.type, survivorData.startingPrimary.ID)
	
	
func _process(delta):
	if isDead:
		return
		
	ReduceBuffDurations(delta)
	
	oxygen -= delta * 3
	if oxygen < 0:
		oxygen = 0
	if oxygen == 0:
		health -= delta
	if oxygen > 100:
		oxygen = 100
		
	sleep -= delta * 0.1 * sleepGainModifier
	if sleep < 0:
		StartSleeping()
	if sleep > 100:
		sleep = 100
	
	nutrition -= delta
	if nutrition < 0:
		nutrition = 0
	if nutrition == 0:
		health -= delta
	
	#
	## high fever
	#if bodyTemperature >= 42:
		#health -= delta * 1
	## moderate fever
	#elif bodyTemperature >= 40:
		#health -= delta * 0.5
	## mild fever
	#elif bodyTemperature >= 38:
		#pass
	#
	## Severe Hypothermia
	#if bodyTemperature <= 28:
		#health -= delta * 1
	## moderate Hypothermia
	#elif bodyTemperature <= 32:
		#health -= delta * 0.5
	## mild Hypothermia
	#elif bodyTemperature <= 34:
		#pass
	
	UpdateHealthBar()
	PointArmAt(get_global_mouse_position())
	
	if reloading:
		reloadUI.visible = true
		reloadUI.progress = reloadTimer.time_left / reloadTimer.wait_time * 100
	else:
		reloadUI.visible = false
		

func _physics_process(delta):
	if isDead:
		return
		
	UpdateStats()
	
	super._physics_process(delta)
	
	muzzleFlashSprite.visible = false
	
	if Input.is_action_pressed("sleep") and sleepingCooldown == false:
		StartSleeping()
	
	# can't wake up til sleep reaches 100
	# can cancel if above 50
	if sleeping:
		sleep += delta * 5
		if sleep >= 100:
			sleep = 100
			sleeping = false
			sleepingParticleEffect.emitting = false
		elif sleep >= 50:
			if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up"):
				sleeping = false
				sleepingParticleEffect.emitting = false
		else:
			return
		
	# player controls
	velocity = Vector2.ZERO # The player's movement vector.
	# Movement input
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	
	if Input.is_action_pressed("run"):
		isRunning = true
	else:
		isRunning = false
		
	attacking = false
	if Input.is_action_pressed("attack_primary"):
		attacking = true
	
	if Input.is_action_pressed("attack_melee"):
		MeleeAttack()
		attacking = false
		
	# reload
	if Input.is_action_pressed("reload"):
		Reload()
		
	# Shot input
	if attacking and attackCooldown == false and reloading == false and not usingSkill and not sleeping:
		attackTimer.start(1/primarySlot.data.attacksPerSecond)
		attackCooldown = true
		Attack()
		
	# Normalize velocity if move along x and y together
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		#move_trail_effect.emitting = true # Play movement trail effect
	# Limit the player movement, add your character scale if needed
	move_and_slide()
	
	
	var results = interactionArea.get_overlapping_bodies()
	if results.size() >= 1:
		results[0].available = true
		interactionObject = results[0]
		
		UserInterfaceManager.UpdateInteractionUI(self)
	else:
		interactionObject = null
		UserInterfaceManager.CloseInteractionWindows()
	
	if Input.is_action_pressed("interact"):
		if interactionObject != null:
			interactionObject.Fix(delta)

	
# need to make it so that the angle is offset based on accuracy
func Attack():
	if primarySlot.data is RangedWeapon:
		for i in range(primarySlot.data.projectilesPerShot):
			var newBullet = bulletScene.instantiate()
			Game.gameScene.add_child(newBullet)
			newBullet.weapon = primarySlot
			newBullet.from = self
			newBullet.position = attackPoint.global_position
			newBullet.rotation = attackPoint.global_position.angle_to_point(get_global_mouse_position()) + randf_range(-spread, spread)
			muzzleFlashSprite.visible = true
			newBullet.speed = primarySlot.data.projectileSpeed
		
		if not primarySlot.data.isLaserWeapon:
			magazineCount -= 1
		
		# shooting sound effect
		audioPlayer.play()
		
		# screen shake
		Camera.ShakeScreen(3,3)
		
		# check if need reload
		if magazineCount <= 0 and not primarySlot.data.isLaserWeapon:
			Reload()
	
	
func Reload():
	if not reloading and primarySlot.type == ItemType.Ranged and magazineCount != primarySlot.data.magazineCapacity:
		$ReloadTimer.start(primarySlot.data.reloadTime * reloadSpeed)
		reloading = true
	

func MeleeAttack():
	if meleeCooldown or sleeping:
		return
	
	var results = meleeAttackArea.get_overlapping_bodies()
	for item in results:
		if item is Enemy:
			item.ReceiveHit(self, randi_range(20, 40), 0, false, 200)
	meleeCooldown = true
	meleeAttackTimer.start()
	animationPlayer.play("melee_thrust_attack_animation")
	
# takes in where, which slot to put item into, and what, which is the index of the item being moved inside inventory.
func EquipItemFromInventory(what: int, where: int):
	equipmentSlots[where] = what
	

func EquipNewItem(item: Item, where: int):
	if where == SlotType.Head:
		headSlot = item
	if where == SlotType.Body:
		bodySlot = item
	if where == SlotType.Primary:
		primarySlot = item
		
	inventoryWeight += item.data.weight
	
	UpdateStats()


func UpdateStats():
	# equip fists as default
	var primary = Item.new(0,0)
	
	if primarySlot != null:
		primary = primarySlot
	
	if primary.data is RangedWeapon:
		if magazineCount > primary.data.magazineCapacity:
			magazineCount = primary.data.magazineCapacity
			
	var head = headSlot
	var body = bodySlot
	
	defense = 0
	radiationDefense = 0
	if head != null:
		defense += head.data.defense
		radiationDefense += head.data.radiationDefense
	
	if body != null:
		defense += body.data.defense
		radiationDefense += body.data.radiationDefense
	
	inventoryCapacity = strength * 2
	inventoryWeight = 0
	# recalculate inventory weight
	for item: Item in inventory:
		if item != null:
			inventoryWeight += item.data.weight
	
	if headSlot != null:
		inventoryWeight += headSlot.data.weight
	if bodySlot != null:
		inventoryWeight += bodySlot.data.weight
	if primarySlot != null:
		inventoryWeight += primarySlot.data.weight
	
	# set to base speed
	speed = survivorData.speed
	
	# modify speed based on inventory weight
	if inventoryWeight > inventoryCapacity:
		speedModifier = 1 - (inventoryWeight - inventoryCapacity) / float(inventoryCapacity)
		if speedModifier < 0:
			speedModifier = 0
	else:
		speedModifier = 1
	
	if sleep < 20:
		speedModifier -= 0.2
	if sleep > 95:
		speedModifier += 0.2
		
	speed *= speedModifier
	
	if isRunning:
		speed *= 1.5
	
	self.attackSpeedModifier = 1
	self.defenseModifier = 1
	
	for item: BuffObject in self.buffs:
		speed *= 1 + item.data.speedModifer
		self.attackSpeedModifier += item.data.attackSpeedModifier
		endAccuracy += item.data.accuracyAmount
		defense += item.data.defenseAmount

	if primary != null:
		attackTimer.wait_time = (1 / primary.data.attacksPerSecond + randf_range(-0.01,0.01))/self.attackSpeedModifier
		endAccuracy = accuracy + primary.data.accuracy
	
	# update weapon bullet spread
	spread = 2 * atan(25.0/primary.data.range)
	
	if isRunning:
		spread *= 2
	elif velocity != Vector2.ZERO:
		spread *= primary.data.movementPenalty
	
	if sleep < 20:
		spread *= 2
	elif sleep > 95:
		spread *= 0.5
		

func PointArmAt(pos):
	# turn towards target
	armSprite.rotation = global_position.angle_to_point(pos)


func OnDeath():
	if isDead:
		return
		
	isDead = true
	print("survivor dead!")
	$BodyCollisionShape.set_deferred("disabled", true)
	$ArmSprite.visible = false
	

func StartSleeping():
	if sleeping == true:
		return
		
	sleeping = true
	sleepingCooldown = true
	
	if sleepingCooldownTimer.is_stopped():
		sleepingCooldownTimer.start()
	
	sleepingParticleEffect.emitting = true
	
	
# simulates breathing in
func _on_oxygen_timer_timeout():
	oxygen += 10 * Spaceship.oxygenLevel / 100.0
	if headSlot != null:
		oxygen += headSlot.data.oxygenGeneration
	
	if oxygen < 0:
		oxygen = 0
	
	if oxygen > 100:
		oxygen = 100
	

func _on_temperature_timer_timeout():
	var diff = Spaceship.temperature - bodyTemperature
	
	bodyTemperature += 0.01 * diff
		
		
func _on_nutrition_timer_timeout():
	# consume food
	if Spaceship.ConsumeFood(1):
		nutrition += 30


func AddItemByIndex(type, id):
	var index = Survivor.GetFirstEmptySlot(inventory)
	inventory[index] = Item.new(type, id)
	inventoryWeight += DataManager.resources[type][id].weight
	UpdateStats()


func AddItem(item: Item):
	var index = Survivor.GetFirstEmptySlot(inventory)
	inventory[index] = item
	inventoryWeight += item.data.weight
	UpdateStats()
	
	
func RemoveByIndex(index):
	var item = inventory[index]
	
	# find equipped slot number
	var num = equipmentSlots.find(index)
	if num > -1:
		equipmentSlots[num] = -1
	
	inventory.remove_at(index)
	inventoryWeight -= item.data.weight
	
	# change index of slots that come later in inventory
	for i in len(equipmentSlots):
		if equipmentSlots[i] > index:
			equipmentSlots[i] -= 1
			
	UpdateStats()
	
	return item
		

func AddExperiencePoints(amount):
	experiencePoints += amount
	if experiencePoints >= requiredEXP:
		level += 1
		requiredEXP  *= 1.5
		experiencePoints = 0
		levelUpEffect.play("level_up_anim")
	
	UpdateExpBar()
	

func UpdateExpBar():
	expBar.size.x = experiencePoints/float(requiredEXP) * healthBarSize


# reduce duration times of buff objects and remove them if they are expired
func ReduceBuffDurations(delta):
	var buffsSize = self.buffs.size()
	for i in range(buffsSize):
		var index = buffsSize - 1 - i
		self.buffs[index].durationLeft -= delta
		if self.buffs[index].durationLeft < 0:
			self.buffs.remove_at(index)
		
		
func ApplySkillCooldown(skill: Skill):
	if skill == skillSlot_1:
		skillCooldownTimer1.start(skill.cooldownTime)
		skillReady_1 = false
	elif skill == skillSlot_2:
		skillCooldownTimer2.start(skill.cooldownTime)
		skillReady_2 = false
	
	
func _to_string():
	var output: String = "Survivor Info\n"
	output += "HP: " + str(int(health)) + " / " + str(maxHealth) + "\n"
	output += "Speed: " + str(speed * speedModifier) + "\n"
	output += "Defense: " + str(defense * 100) + "%\n"
	output += "Oxygen: " + str(int(oxygen * 100) / 100) + "%\n"
	output += "Body Temperature: " + str(bodyTemperature) + "C\n"
	
	return output
	

func PrintEquipmentStatus():
	var output: String = "Equipment\n"
	if equipmentSlots[SlotType.Primary] >= 0:
		output += "Primary Weapon: " + inventory[equipmentSlots[SlotType.Primary]].data.name + "\n"
	else:
		output += "Primary: None" + "\n"
		
	if equipmentSlots[SlotType.Head] >= 0:
		output += "Head: " + inventory[equipmentSlots[SlotType.Head]].data.name + "\n"
	else:
		output += "Head: None" + "\n"
		
	if equipmentSlots[SlotType.Body] >= 0:
		output += "Body: " + inventory[equipmentSlots[SlotType.Body]].data.name + "\n"
	else:
		output += "Body: None" + "\n"
		
	return output


static func GetFirstEmptySlot(list):
	for i in len(list):
		if list[i] == null:
			return i
	
	return -1
	
	
func PrintHealthStats() -> String:
	var output = "Health Stats:\n"
	output += "HP: " + str(int(health * 100) / 100.0) + "/" + str(maxHealth) + "\n"
	output += "Temp: " + str(int(bodyTemperature * 10000) / 10000.0) + "C\n"
	output += "Oxygen: " + str(int(oxygen * 100) / 100) + "%\n"
	output += "Nutrition: " + str(int(nutrition * 100) / 100) + "%\n"
	output += "Sleep: " + str(int(sleep * 100)/100) + "%\n"
	
	return output


func PrintCombatStats() -> String:
	var output = "Combat Stats:\n"
	output += "Speed: " + str(int(speed)) + "\n"
	output += "Strength: " + str(strength) + "\n"
	output += "Accuracy: " + str(int(endAccuracy * 100) / 100) + "%\n"
	output += "Evasion" + str(int(evasion * 100) / 100) + "%\n"
	output += "Defense: " + str(int(defense * 100)) + "%\n"
	output += "Rad. Defense: " + str(int(radiationDefense * 100) / 100) + "%\n"
	
	return output
	
	
func PrintMiscStats() -> String:
	var output = "Name Here\n"
	output += "Character job here\n"
	output += "LV: " + str(level) + "\n"
	output += str(experiencePoints) + "/" + str(requiredEXP) + "\n"
	return output


func _on_attack_timer_timeout():
	attackCooldown = false


func _on_reload_timer_timeout():
	reloading = false
	magazineCount = primarySlot.data.magazineCapacity
	Spaceship.ConsumeAmmo(primarySlot.data.ammoPerReload)


# skill cooldown over. enable them
func _on_skill_cooldown_timer_timeout(extra_arg_0):
	if extra_arg_0 == 0:
		skillReady_1 = true
	elif extra_arg_0 == 1:
		skillReady_2 = true


func _on_melee_attack_timer_timeout():
	meleeCooldown = false


func _on_sleep_cooldown_timer_timeout():
	sleepingCooldown = false
