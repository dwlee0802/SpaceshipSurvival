extends Node2D

class_name Module

static var errorRate: float = 0.1

var interactablesNode

var isOperational: bool = true

var interactables = []

var spawnPoints = []

var overviewMarker

var recentlyHadError: bool = false

@onready var errorCooldownTimer: Timer = $ErrorCooldownTimer


func _ready():
	interactablesNode = get_node_or_null("Interactables")
	
	if interactablesNode != null:
		for item in interactablesNode.get_children():
			interactables.append(item)
	
	$ErrorTimer.timeout.connect(GenerateErrors)
	#overviewMarker = UserInterfaceManager.MakeMarkerOnSpaceshipOverview()
	#overviewMarker.self_modulate = Color.RED
	#overviewMarker.position = global_position / 5.80708
	#overviewMarker.get_node("Label").text = "!"
	#overviewMarker.visible = false


func _process(_delta):
	isOperational = CheckOperational()
	
	# update overview UI if something changed
	#if overviewMarker.visible == isOperational:
		#overviewMarker.visible = not isOperational
		#UserInterfaceManager.UpdateSpaceshipOverviewText()
	

func CheckOperational():
	for item in interactables:
		if item.timeToFix > 0:
			return false
	
	# interactables got fixed and operational status changed
	if isOperational == false:
		isOperational = true
		errorCooldownTimer.start()
		
	return true


func GenerateErrors():
	if recentlyHadError:
		return
		
	for item in interactables:
		if item.timeToFix <= 0:
			if randf() < errorRate:
				item.timeToFix = randi_range(3, 6)
	
				recentlyHadError = true
	

func _on_error_cooldown_timer_timeout():
	print(name + "'s error spawn cd is done.")
	recentlyHadError = false
