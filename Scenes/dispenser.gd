extends Interactable
class_name Dispenser

enum DispenserType {Food, Ammo}
@export var type: DispenserType

var cooldown: bool = false
@onready var cooldownTimer = $CooldownTimer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fixTimeLabel.text = str(int(cooldownTimer.time_left * 100) / 100.0)


func _on_cooldown_timer_timeout():
	cooldown = false


func Fix(delta):
	if cooldown:
		return
		
	if type == DispenserType.Food:
		print("refill food")
		Game.survivor.nutrition = 100
	elif type == DispenserType.Ammo:
		if Game.survivor.primarySlot is Gun:
			print("refill ammo")
			Game.survivor.primarySlot.RefillAmmo()
		
	cooldown = true
	cooldownTimer.start()
