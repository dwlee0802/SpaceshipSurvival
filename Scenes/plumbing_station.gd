extends Interactable
class_name PlumbingRoom


var recentlyHadError: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()


func CheckOperational():
	if timeToFix > 0:
		return false
			
	if isOperational == false:
		isOperational = true
		
	return true
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
	if not CheckOperational():
		DrinkingStation.plumbingOperational = false
	else:
		DrinkingStation.plumbingOperational = true


func GenerateErrors():
	if recentlyHadError:
		return
		
	if timeToFix <= 0:
		if randf() < Interactable.errorRate:
			timeToFix = randi_range(3, 5)
	
			recentlyHadError = true
	
	
func _on_error_spawn_timer_timeout():
	GenerateErrors()


func _on_error_cooldown_timer_timeout():
	recentlyHadError = false
