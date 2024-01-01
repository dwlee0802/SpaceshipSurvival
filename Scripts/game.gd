extends Node2D

class_name Game

static var survivor

static var enemies = []
static var MAX_ENEMY_COUNT: int = 10

static var time: float = 0

static var damagePopup = preload("res://Scenes/damage_popup.tscn")
static var deathEffect = preload("res://Scenes/death_particle_effect.tscn")

static var enemyHitEffectScene = preload("res://Scenes/hit_particle_effect.tscn")

static var areaEffectScene = preload("res://Scenes/area_effect.tscn")

static var explostionEffect = preload("res://Scenes/explosion_effect.tscn")

static var projectileScene = preload("res://Scenes/projectile.tscn")

static var gameScene: Game

static var spaceship

const AMMO_PER_STR: int = 200
const FOOD_PER_STR: int = 2
const COMP_PER_STR: int = 10

static var components: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	survivor = $Survivor
	gameScene = self
	spaceship = $Spaceship
	

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
	newEff.global_position = where
	gameScene.add_child(newEff)
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


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
