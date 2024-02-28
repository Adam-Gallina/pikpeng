extends Node2D
class_name AbstractStorage

signal storage_filled(storage:Node)
signal storage_emptied(storage:Node)

signal storage_changed(amount:int, maximum:int)

@export var ignore_max_storage = false
@export var base_max_storage = 10
@export var deposit_point : Node2D
@export var withdraw_point : Node2D

@export var curr_stored : Array[Geode] = []

func _ready():
	for i in curr_stored:
		if i.get_parent(): 
			i.get_parent().remove_child(i)

var spawned = false
func spawn():
	spawned = true
	if curr_stored.size() >= calc_max_storage():
		storage_filled.emit(self)
	else:
		storage_emptied.emit(self)
	storage_changed.emit(curr_stored.size(), calc_max_storage())

func withdraw(amount:int):
	var removed = curr_stored.size() if amount >= curr_stored.size() else amount
	var ret : Array[Geode] = []
	for i in range(removed): ret.append(curr_stored.pop_front())
	
	storage_emptied.emit(self)
	storage_changed.emit(curr_stored.size(), calc_max_storage())
	
	return ret

func deposit(geodes:Array[Geode]):
	curr_stored.append_array(geodes)
	on_deposit(geodes)

func on_deposit(_geodes:Array[Geode]):
	storage_changed.emit(curr_stored.size(), calc_max_storage())


func storage_full():
	return not ignore_max_storage and curr_stored.size() >= calc_max_storage()
	
func calc_max_storage():
	return base_max_storage

	
func save():
	var data = []

	for i in curr_stored:
		data.append(i.save())

	return { 'curr_stored' : data	}

func on_load(data : Dictionary):
	for i in data['curr_stored']:
		var item = load(i["filename"]).instantiate()
		item.on_load(i)
		curr_stored.append(item)

	storage_changed.emit(curr_stored.size(), calc_max_storage())
