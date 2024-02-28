extends Control
class_name UpgradeUI

@export var label_text = "<upgrade name>: lvl %d"
@export var button_text = "Buy: %d"
@export var use_gold = false
@export var use_coin_price_upgrade = true
@export var upgrade : AbstractUpgrade

@onready var label : Label = $Label
@onready var button : Button = $Button

func set_text():
	label.text = label_text % upgrade.level
	var val = upgrade.cost()
	if use_coin_price_upgrade:
		val *= Constants.GoldUpgrades.coin_upgrade_cost.calc()
	button.text = button_text % int(val)
	if button.get_node('Coin').get_child_count() == 1: button.text += '    '

	if use_gold:
		button.disabled = !Stats.can_gold_upgrade(val)
	else:
		button.disabled = !Stats.can_upgrade(val)
