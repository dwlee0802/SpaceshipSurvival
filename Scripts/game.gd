extends Node2D

class_name Game

static var survivors = []

static var enemies = []

static var time: float = 0

static var damagePopup = preload("res://Scenes/damage_popup.tscn")
static var deathEffect = preload("res://Scenes/death_particle_effect.tscn")

static var gameScene: Game

static var spaceship

const AMMO_PER_STR: int = 200
const FOOD_PER_STR: int = 2


# Called when the node enters the scene tree for the first time.
func _ready():
	survivors.append($Survivor)
	survivors.append($Survivor2)
	gameScene = self
	spaceship = $Spaceship


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var count = len(survivors)
	for i in count:
		if survivors[i].isDead:
			count -= 1
	
	if count <= 0:
		print("Game Over!")


static func UpdateEnemyTargetPosition():
	for item in enemies:
		if is_instance_valid(item):
			if item.attackTarget != null:
				item.ChangeTargetPosition(item.attackTarget.position)
		else:
			enemies.erase(item)


static func SetSelectionUI(value):
	for item in survivors:
		item.ShowSelectionUI(value)


static func MakeDamagePopup(where, amount, color = Color.DARK_RED):
	var newPopup = damagePopup.instantiate()
	newPopup.position = where
	newPopup.modulate = color
	if amount != 0:
		newPopup.get_node("Label").text = "[center][b]" + str(amount) + "[/b][/center]"
	else:
		newPopup.get_node("Label").text = "[center][b]" + "MISS" + "[/b][/center]"
		
	gameScene.add_child(newPopup)


static func MakeEnemyDeathEffect(where):
	var thing = deathEffect.instantiate()
	thing.global_position = where
	thing.emitting = true
	gameScene.add_child(thing)
	

static func UpdateStockMax():
	Spaceship.maxAmmoStock = 0
	Spaceship.maxFoodStock = 0
	
	for item in survivors:
		Spaceship.maxAmmoStock += item.strength * AMMO_PER_STR
		Spaceship.maxFoodStock += item.strength * FOOD_PER_STR


static func GetClosestSurvivor(position):
	var result = survivors[0]
	var smallestDist = survivors[0].position.distance_to(position)
	
	for item in survivors:
		var dist = item.position.distance_to(position)
		if smallestDist > dist:
			result = item
			smallestDist = dist
	
	return result


static func GainExperiencePoints(main, amount):
	for item : Survivor in survivors:
		if item == main:
			item.AddExperiencePoints(amount * 2)
		else:
			item.AddExperiencePoints(amount)
			
