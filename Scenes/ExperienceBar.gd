extends Control

@onready var bar = $TextureRect
@onready var maxLen = $Background.size.x
@onready var label = $Label

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	bar.size.x = (Game.survivor.experiencePoints / float(Game.survivor.requiredEXP)) * maxLen
	label.text = "EXP: " + str(Game.survivor.experiencePoints) + " / " + str(Game.survivor.requiredEXP)
