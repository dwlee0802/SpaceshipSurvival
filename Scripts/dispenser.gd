extends Interactable
class_name Dispenser

enum DispenserType {Food, Ammo}
@export var type: DispenserType

var cooldown: bool = false
@onready var cooldownTimer = $CooldownTimer

@onready var foodSoundEffect = $FoodRefillAudio
@onready var ammoSoundEffect = $AmmoRefillAudio

var ammoTexture = load("res://Art/ammo_icon.png")
var foodTexture = load("res://Art/nutrition_icon.png")


func _ready():
	super._ready()
	
	if type == DispenserType.Food:
		sprite.texture = foodTexture
	elif type == DispenserType.Ammo:
		sprite.texture = ammoTexture
		
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fixTimeLabel.text = str(int(cooldownTimer.time_left * 10) / 10.0)


func _on_cooldown_timer_timeout():
	cooldown = false


func Fix(delta):
	if cooldown:
		return
		
	if type == DispenserType.Food:
		print("refill food")
		Game.survivor.nutrition = 100
		foodSoundEffect.play()
	elif type == DispenserType.Ammo:
		if Game.survivor.primarySlot is Gun:
			print("refill ammo")
			Game.survivor.primarySlot.Reload()
			Game.survivor.primarySlot.RefillAmmo()
			ammoSoundEffect.play()
		
	cooldown = true
	cooldownTimer.start()
