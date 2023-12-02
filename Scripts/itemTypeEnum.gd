extends Node

class_name ItemType

enum {Melee, Ranged, Head, Body, Consumable}

static func ReturnString(num):
	if num == 0:
		return "Melee"
	if num == 1:
		return "Ranged"
	if num == 2:
		return "Head"
	if num == 3:
		return "Body"
	if num == 4:
		return "Consumable"
