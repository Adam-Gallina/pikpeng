extends Node
class_name Geode

## Time for a level 1 chute to process
@export var strength = 2
@export var value = 1
@export var resource_type = 0

func extract(mod : float = 1):
	if resource_type == Constants.RESOURCE.COIN:
		Stats.total_coins += int(value * mod)
	elif resource_type == Constants.RESOURCE.GOLD:
		Stats.total_gold += int(value * mod)
	return int(value * mod)

func save():
	return {
		'filename' : get_scene_file_path(),
		'strength' : strength,
		'value' : value,
		'type' : resource_type
	}

func on_load(data : Dictionary):
	strength = data['strength']
	value = data['value']
	resource_type = data['type']
