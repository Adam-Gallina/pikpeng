extends Control

signal building_created(building_type, dir)
signal building_added(building_type, dir)

@export var MineScene : PackedScene
@export var ChuteScene : PackedScene
@export var BuildingDist : float = 250

@onready var building_btn_parent = $BuyButton
@onready var building_btn : Button = $BuyButton/Button
@onready var building_cost : AbstractUpgrade = $BuyButton/MineCost

var built_buildings = 0
var Mines = []
var Chutes = []

var selected_mines = []

func add_chute():
	var x = calc_building_x()
	Chutes.append(add_building(ChuteScene, Vector2(x, 0)))
	built_buildings += 1
	building_created.emit(Constants.BUILDING.CHUTE, -1 if x < 0 else 1)
	update_ui()

func append_chute(chute : Chute, pos : Vector2):
	Chutes.append(append_building(chute, pos))
	built_buildings += 1
	building_added.emit(Constants.BUILDING.CHUTE, -1 if pos.x < 0 else 1)
	update_ui()

func add_mine():
	var x = calc_building_x()
	Mines.append(add_building(MineScene, Vector2(x, 0)))
	built_buildings += 1
	building_created.emit(Constants.BUILDING.MINE, -1 if x < 0 else 1)
	update_ui()

func append_mine(mine : GeodeMine, pos : Vector2):
	Mines.append(append_building(mine, pos))
	built_buildings += 1
	building_cost.level += 1
	building_added.emit(Constants.BUILDING.MINE, -1 if pos.x < 0 else 1)
	update_ui()


func replace_building(old : AbstractBuilding, new : AbstractBuilding):
	var arr = []

	if old in Mines: arr = Mines
	elif old in Chutes: arr = Chutes

	arr.erase(old)
	arr.append(new)

func add_building(building : PackedScene, pos : Vector2, spawn = true):
	var b = building.instantiate()
	add_child(b)
	b.position = pos
	if spawn: b.spawn()

	return b

func append_building(building : AbstractBuilding, pos : Vector2):
	add_child(building)
	building.position = pos
	building.spawn()

	return building

func _on_buy_mine_pressed():
	if Stats.can_upgrade(calc_mine_cost(), true):
		add_mine()
		building_cost.level += 1
		update_ui()


func update_ui():
	building_btn_parent.position = Vector2(calc_building_x(), 0)
	building_btn.text = "Buy Mine: %d       " % calc_mine_cost()
	building_btn.disabled = !Stats.can_upgrade(calc_mine_cost())


func calc_mine_cost():
	return building_cost.calc()

func calc_building_x():
	var dir = 1 if built_buildings % 2 == 0 else -1
	var offset = (built_buildings + 1) / 2

	return offset * dir * BuildingDist

func calc_map_size():
	return (built_buildings - 1) * BuildingDist

func count_left():
	return built_buildings / 2

func count_right():
	return (built_buildings - 1) / 2


func get_mine(pos, curr=null):
	if Mines.size() == 0:
		print('No mines available')
		return null
	
	var mine = null
	var weight = -1
	for m in Mines:
		if m == curr:
			continue
		if m in selected_mines:
			continue

		var w = m.calc_weight(pos)
		if w > weight:
			mine = m
			weight = w
			
	if mine == null:
		print('No mine found')
		return null
	
	selected_mines.append(mine)
	return mine

func on_withdraw_mine(mine):
	selected_mines.erase(mine)

func clear_selected_mines():
	selected_mines = []
