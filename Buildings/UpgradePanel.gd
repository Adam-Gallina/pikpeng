extends CanvasLayer
class_name UpgradePanel

@export var SignMargins : Vector2 = Vector2(50, 25)

func update_ui():	
	if $Sign.size.x != $Sign/Sidebar.size.x + SignMargins.x * 2:
		scale_sign()

	for c in $Sign/Sidebar.get_children():
		# Ignore spacers
		if c is Label: continue

		# Ignore locked upgrades
		if not c.visible: continue
		
		c.set_text()

func scale_sign():
	var size = $Sign/Sidebar.size
	#var ta = $Sign.size.y / $Sign.size.x
	#var ba = $Sign/Middle/Bottom.size.y / $Sign/Middle/Bottom.size.x
	size += SignMargins * 2

	#$Sign.size.x = size.x
	#$Sign.size.y = size.x * ta
	#$Sign/Middle/Bottom.size.y = size.x * ba

	size.y -= ($Sign.size.y + $Sign/Middle/Bottom.size.y)
	if size.y < 0: size.y = 0
	$Sign/Middle.size.y = size.y

	#$Sign/Sidebar.position = SignMargins


func do_coin_upgrade(upgrade : AbstractUpgrade, use_coin_price_upgrade=true):
	var val = upgrade.cost()
	if use_coin_price_upgrade:
		val *= Constants.GoldUpgrades.coin_upgrade_cost.calc()

	if Stats.can_upgrade(val, true):
		upgrade.level += 1
		return true
	return false
	
func do_gold_upgrade(upgrade : AbstractUpgrade):
	if Stats.can_gold_upgrade(upgrade.cost(), true):
		upgrade.level += 1
		return true
	return false

func save():
	return {}

func on_load(_data : Dictionary):
	pass