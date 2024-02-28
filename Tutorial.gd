extends Control

signal mine_filled

func get_tut_node(node_name : String):
	var n = get_node(node_name)
	n.hide()
	return n

@onready var tut_buy_mine = get_tut_node('BuyMine')
@onready var tut_select_mine = get_tut_node('SelectMine')
@onready var tut_upgrades = get_tut_node('CanvasLayer/OpenUpgrades')
@onready var tut_buy_peng = get_tut_node('CanvasLayer/BuyPeng')
@onready var tut_collect_geode = get_tut_node('CollectGeode')
@onready var tut_select_chute = get_tut_node('SelectChute')
@onready var tut_buy_peng_2 = get_tut_node('CanvasLayer/BuyPeng2')
@onready var tut_gold_upgrades = get_tut_node('CanvasLayer/OpenGoldUpgrades')
@onready var tut_buy_shoes = get_tut_node('CanvasLayer/BuyShoes')
@onready var tut_complete = get_tut_node('CanvasLayer/Completed')

func _ready():
	hide()
	$CanvasLayer.hide()

var collected = false
func _process(_delta):
	if not visible: return

	if tut_collect_geode.visible:
		var mine = Constants.BuildingController.Mines[0]
		if mine.pengs.size() != 2: return
		var p = mine.pengs[1]
		if not collected and p.curr_carry.size() > 0:
			collected = true
		elif collected and p.curr_carry.size() == 0:
			mine_filled.emit()

func start_tutorial():
	show()
	$CanvasLayer.show()
	buy_mine()

func buy_mine():
	var buy_btn : Button = Constants.Main.get_node('Buildings/BuyButton/Button')

	tut_buy_mine.show()
	await buy_btn.pressed
	tut_buy_mine.hide()

	Constants.BuildingController.get_node('BuyButton').hide()

	select_mine()

func select_mine():
	var mine = Constants.BuildingController.Mines[0]

	tut_select_mine.show()
	await mine.on_focus
	tut_select_mine.hide()

	open_upgrades()

func open_upgrades():
	if Constants.MainUI.UiState.UpgradePanel:
		Constants.MainUI.toggle_upgrade_panel()

	tut_upgrades.show()
	await Constants.MainUI.set_upgrade_panel
	tut_upgrades.hide()

	buy_peng()

func buy_peng():
	var mine = Constants.BuildingController.Mines[0]
	var btn = mine.get_node('UpgradeUI/Sign/Sidebar/PengCount/Button')

	tut_buy_peng.show()
	await btn.pressed
	tut_buy_peng.hide()

	collect_geode()

func collect_geode():
	tut_collect_geode.show()
	await mine_filled
	tut_collect_geode.hide()

	select_chute()

func select_chute():
	var chute = Constants.BuildingController.Chutes[0]

	tut_select_chute.show()
	await chute.on_focus
	tut_select_chute.hide()

	buy_chute_peng()

func buy_chute_peng():
	if not Constants.MainUI.UiState.UpgradePanel:
		tut_upgrades.show()
		await Constants.MainUI.set_upgrade_panel
		tut_upgrades.hide()

	var chute = Constants.BuildingController.Chutes[0]
	var btn = chute.get_node('UpgradeUI/Sign/Sidebar/PengCount/Button')

	tut_buy_peng_2.show()
	await btn.pressed
	tut_buy_peng_2.hide()

	open_gold_upgrades()

func open_gold_upgrades():
	if Constants.GoldUpgrades.panel_open:
		Constants.GoldUpgrades._on_toggle_pressed()
	
	var btn = Constants.GoldUpgrades.get_node('Toggle')

	tut_gold_upgrades.show()
	await btn.pressed
	tut_gold_upgrades.hide()

	buy_shoes()

func buy_shoes():
	var btn = Constants.GoldUpgrades.get_node('Sign/Sidebar/GlobalPengSpeed/Button')

	tut_buy_shoes.show()
	await btn.pressed
	tut_buy_shoes.hide()

	tut_complete.show()

func _on_tutorial_completed():
	hide()
	$CanvasLayer.hide()
	Constants.BuildingController.get_node('BuyButton').show()
	UserData.save_all_data()
