extends UpgradePanel

var panel_open : bool
func _ready():
	show()
	$AnimationPlayer.play('panel_open')
	$AnimationPlayer.stop()
	panel_open = false

func _on_toggle_pressed():
	$AnimationPlayer.play('panel_close' if panel_open else 'panel_open')
	panel_open = not panel_open

func update_ui():
	super()

	if not $Sign/Sidebar/GlobalBucketSpeed.visible:
		for m in Constants.BuildingController.Mines:
			if 'T2' in m.name:
				$Sign/Sidebar/GlobalBucketSpeed.show()


signal on_upgrade_coin_value
@export var coin_value : AbstractUpgrade
signal on_upgrade_coin_upgrade_cost
@export var coin_upgrade_cost : AbstractUpgrade

signal on_upgrade_global_peng_speed
@export var global_peng_speed : AbstractUpgrade
signal on_upgrade_global_peng_carry
@export var global_peng_carry : AbstractUpgrade

signal on_upgrade_global_bucket_speed
@export var global_bucket_speed : AbstractUpgrade


func _on_upgrade_coin_value_pressed():
	if do_gold_upgrade(coin_value):
		on_upgrade_coin_value.emit()

func _on_upgrade_coin_prices_pressed():
	if do_gold_upgrade(coin_upgrade_cost):
		on_upgrade_coin_upgrade_cost.emit()

func _on_upgrade_peng_speed_pressed():
	if do_gold_upgrade(global_peng_speed):
		on_upgrade_global_peng_speed.emit()

func _on_upgrade_peng_carry_pressed():
	if do_gold_upgrade(global_peng_carry):
		on_upgrade_global_peng_carry.emit()

func _on_upgrade_bucket_speed_pressed():
	if do_gold_upgrade(global_bucket_speed):
		on_upgrade_global_bucket_speed.emit()


func save():
	var ret = super()

	ret['coin_value'] = coin_value.level
	ret['upgrade_cost'] = coin_upgrade_cost.level
	ret['peng_speed'] = global_peng_speed.level
	ret['peng_carry'] = global_peng_carry.level
	ret['bucket_speed'] = global_bucket_speed.level
	
	ret['bucket_unlocked'] = $Sign/Sidebar/GlobalBucketSpeed.visible

	return ['gold_upgrades', ret]

func on_load(data : Dictionary):
	super(data)
	
	coin_value.level = data['gold_upgrades']['coin_value']
	coin_upgrade_cost.level = data['gold_upgrades']['upgrade_cost']
	global_peng_speed.level = data['gold_upgrades']['peng_speed']
	global_peng_carry.level = data['gold_upgrades']['peng_carry']
	global_bucket_speed.level = data['gold_upgrades']['bucket_speed']

	$Sign/Sidebar/GlobalBucketSpeed.visible = data['gold_upgrades']['bucket_unlocked']
