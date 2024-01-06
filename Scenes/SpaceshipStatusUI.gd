extends Control

@onready var oxygenIcon = $OxygenGeneratorStatus
@export var oxygen_r: Texture2D
@export var oxygen_g: Texture2D
@export var oxygen_y: Texture2D

@onready var nuclearIcon = $NuclearReactorStatus
@export var nuclear_r: Texture2D
@export var nuclear_g: Texture2D
@export var nuclear_y: Texture2D

@onready var tempIcon = $TemperatureStatus
@export var temp_r: Texture2D
@export var temp_g: Texture2D
@export var temp_y: Texture2D


# Update spaceship status UI color according to module status
func _process(delta):
	if not Spaceship.modules[Spaceship.ModuleName.Nuclear_Reactor].isOperational:
		nuclearIcon.texture = nuclear_r
	else:
		nuclearIcon.texture = nuclear_g
		
	if not Spaceship.modules[Spaceship.ModuleName.Oxygen_Generator].isOperational:
		oxygenIcon.texture = oxygen_r
	else:
		oxygenIcon.texture = oxygen_g
		
	if not Spaceship.modules[Spaceship.ModuleName.Nuclear_Reactor].isOperational:
		tempIcon.texture = temp_r
	else:
		tempIcon.texture = temp_g
