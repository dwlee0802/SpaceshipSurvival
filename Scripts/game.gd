extends Node2D

class_name Game

static var survivors = []

static var time: float = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	survivors.append($Survivor)
	survivors.append($Survivor2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
