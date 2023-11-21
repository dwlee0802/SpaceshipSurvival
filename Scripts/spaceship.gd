extends Node

var oxygenLevel: int = 100

@export var modules = []

enum ModuleName {Nuclear_Reactor, Life_Support, Infirmary, Kitchen, Bridge, Engine_Room, Electricity_Room}


# Called when the node enters the scene tree for the first time.
func _ready():
	modules.append($Module)
	modules.append($Module2)
	modules.append($Module3)
	modules.append($Module4)
	modules.append($Module5)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
