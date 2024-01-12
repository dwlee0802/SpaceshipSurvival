extends Control

@onready var bar = $TextureRect
@onready var maxLen = $Background.size.x
@onready var label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	bar.size.x = (Game.survivor.health / Game.survivor.maxHealth) * maxLen
	label.text = "HP: " + str(int(Game.survivor.health * 100) / 100.0) + " / " + str(Game.survivor.maxHealth)
