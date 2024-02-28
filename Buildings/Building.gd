extends AbstractStorage
class_name AbstractBuilding

signal on_focus(building:Node)
signal on_unfocus(building:Node)
var focused = false
signal on_building_replaced(old_building:AbstractBuilding, new_building:AbstractBuilding)

@export var building_width = 100
var purchase_pos : int = -1

@export var next_tier : PackedScene

var pengs = []
@export var penguin_scene : PackedScene
@export var penguin_parent : Node2D = self
@export var penguin_spawn_point : Node2D = self

@export var do_spawn_anims : bool = true
@export var anim_offset : Vector2
@export var coin_anim : PackedScene
@export var gold_anim : PackedScene

@onready var upgrades = $UpgradeUI
@onready var inside = $Inside

var idle_pengs = []

func _ready():
	super()
	unfocus()

	#if Constants.Main == null:
	#	spawn()
	#	focus()

func spawn():
	super()
	spawn_all_pengs()

func spawn_peng(peng):
	peng.global_position = Vector2()
	peng.path.global_position = penguin_spawn_point.global_position
	peng.set_source(self)
	request_new_target(peng, null)
func add_new_peng():
	var peng = penguin_scene.instantiate()
	penguin_parent.add_child(peng)
	pengs.append(peng)
	spawn_peng(peng)
	return peng
func spawn_all_pengs():
	if penguin_parent == null:
		penguin_parent = self
	for i in range(calc_peng_count()):
		add_new_peng()


func add_idle(peng):
	idle_pengs.append(peng)
	peng.set_idle()

func check_end_idle():
	return false

func _process(_delta):
	update_ui()

	if idle_pengs.size() > 0 and check_end_idle():
		for p in idle_pengs.duplicate():
			request_new_target(p, null)
			idle_pengs.erase(p)
			if !check_end_idle():
				break

func update_ui():	
	if !focused: return
	upgrades.update_ui()


func request_new_target(peng, _last_target):
	printerr('request_new_target not defined for ', name, ', setting peng to idle')
	add_idle(peng)

func get_target(peng, _last_target):
	printerr('get_target not defined for ', name, ', setting peng to idle')
	add_idle(peng)

func focus():
	focused = true
	#inside.z_index = 100
	on_focus.emit(self)

func unfocus():
	focused = false
	#inside.z_index = -100
	on_unfocus.emit(self)

func spawn_anim(anim : PackedScene, amount : int):
	if not do_spawn_anims: return
	
	var a = anim.instantiate()
	add_child(a)
	a.start_anim(global_position + anim_offset, amount)


func on_upgrade_building_tier():
	var b : AbstractBuilding = Constants.BuildingController.add_building(next_tier, global_position, false)
	copy_to_building(b)
	b.spawn()
	Constants.BuildingController.replace_building(self, b)
	Constants.MainCam.set_focus(b)

	on_building_replaced.emit(self, b)
	queue_free()

func copy_to_building(new_building : AbstractBuilding):
	upgrades.copy_to(new_building.upgrades)
	for p in pengs:
		deposit(p.curr_carry)
	
	new_building.deposit(curr_stored)


func calc_peng_count():
	return upgrades.peng_count.calc()

func on_upgrade_peng_count():
	add_new_peng()

func calc_peng_speed():
	return upgrades.peng_speed.calc() + Constants.GoldUpgrades.global_peng_speed.calc()

func calc_peng_carry():
	return upgrades.peng_carry.calc() + Constants.GoldUpgrades.global_peng_carry.calc()


var clicked = false
func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed() and !event.is_echo():
			clicked = true
		if event.is_released():
			if event.button_index == MOUSE_BUTTON_LEFT and clicked:
				Constants.MainCam.set_focus(self)
			clicked = false


func save():
	var data = super()

	data['filename'] = get_scene_file_path()
	data['pos_x'] = position.x
	data['pos_y'] = position.y
	data['upgrades'] = upgrades.save() 

	return data

func on_load(data : Dictionary):
	upgrades = $UpgradeUI
	upgrades.on_load(data['upgrades'])

	super(data)

	storage_changed.emit(curr_stored.size(), calc_max_storage())

func on_quit():
	for p in pengs:
		if p.curr_carry.size() > 0:
			deposit(p.curr_carry)
