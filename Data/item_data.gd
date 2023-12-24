extends Resource
class_name ItemData

enum Type {Melee, Ranged, Head, Body, Consumable}


@export var type: Type
@export var name: String
@export var ID: int
@export_multiline var description: String
@export var texture: Texture2D
@export var componentValue: int = 100
@export var weight: int
