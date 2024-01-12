extends Node2D

class_name Game

static var survivor : Survivor

static var enemies = []
static var MAX_ENEMY_COUNT: int = 10

static var time: float = 0

static var damagePopup = load("res://Scenes/damage_popup.tscn")
static var deathEffect = load("res://Scenes/death_particle_effect.tscn")

static var enemyHitEffectScene = load("res://Scenes/hit_particle_effect.tscn")

static var areaEffectScene = load("res://Scenes/area_skill.tscn")

static var explostionEffect = load("res://Scenes/explosion_effect.tscn")
static var explostionSound = load("res://Scenes/sound_effect.tscn")

static var projectileScene = load("res://Scenes/projectile.tscn")

static var gameScene: Game

static var spaceship : Spaceship

const AMMO_PER_STR: int = 200
const FOOD_PER_STR: int = 2
const COMP_PER_STR: int = 10

static var components: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	survivor = $Survivor
	gameScene = self
	spaceship = $Spaceship
	

func _process(delta):
	MAX_ENEMY_COUNT = 10 + 10 * (int(100 * Spaceship.distanceTraveled / Spaceship.DISTANCE_TO_DESTINATION)/5)

	
static func UpdateEnemyTargetPosition():
	for item in enemies:
		if is_instance_valid(item):
			if item.attackTarget != null:
				item.ChangeTargetPosition(item.attackTarget.position)
		else:
			enemies.erase(item)


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


static func MakeExplosionEffect(where):
	var newEff = explostionEffect.instantiate()
	var newSound = explostionSound.instantiate()
	newEff.global_position = where
	gameScene.add_child(newEff)
	newSound.global_position = where
	gameScene.add_child(newSound)
	return newEff


static func MakeEnemyHitEffect(where, angle):
	var newEff = enemyHitEffectScene.instantiate()
	gameScene.add_child(newEff)
	newEff.global_position = where
	newEff.rotation = angle
	return newEff
	

static func MakeAreaEffect():
	var newAreaEffect = areaEffectScene.instantiate()
	gameScene.add_child(newAreaEffect)
	return newAreaEffect
	

static func MakeProjectile():
	return projectileScene.instantiate()
	
	
static func UpdateStockMax():
	Spaceship.maxAmmoStock = 0
	Spaceship.maxFoodStock = 0
	Spaceship.maxComponentStock = 0
	
	var item = survivor
	
	Spaceship.maxAmmoStock += item.strength * AMMO_PER_STR
	Spaceship.maxFoodStock += item.strength * FOOD_PER_STR
	Spaceship.maxComponentStock += item.strength * COMP_PER_STR


static func GainExperiencePoints(_main, amount):
	survivor.AddExperiencePoints(amount)


# restart game
# destroy all enemies
# return survivor to initial state
# reroll item containers
# remove errors in modules
static func Restart():
	gameScene.get_tree().reload_current_scene()
	Spaceship.distanceTraveled = 0
	Spaceship.ammoStock = 0
	Spaceship.componentStock = 0
	Spaceship.foodStock = 0
