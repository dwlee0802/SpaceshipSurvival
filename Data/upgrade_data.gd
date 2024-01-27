extends Resource
class_name Upgrade

@export var name: String = "NULL"
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D
@export var disabled: bool = false

func _to_string():
	var output = ""
	output += name + "\n" + description
	return output
