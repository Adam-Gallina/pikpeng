extends UpgradePanel
class_name BuildingUpgrades

signal on_upgrade_tier
@export var upgrade_tier : AbstractUpgrade

signal on_upgrade_peng_count
@export var peng_count : AbstractUpgrade
signal on_upgrade_peng_speed
@export var peng_speed : AbstractUpgrade
signal on_upgrade_peng_carry
@export var peng_carry : AbstractUpgrade

func _ready():
	if Constants._main_ui != null:
		Constants.MainUI.set_upgrade_panel.connect(_on_set_upgrade_panel)
		_on_set_upgrade_panel(!Constants.MainUI.UiState['UpgradePanel'])
		$AnimationPlayer.stop()
	else:
		hide()
		$AnimationPlayer.play('RESET')


func _on_toggle_pressed():
	Constants.MainUI.toggle_upgrade_panel()

func _on_set_upgrade_panel(panel_open):
	$AnimationPlayer.play('panel_open' if panel_open else 'panel_close')
	

func copy_to(other : BuildingUpgrades):
	peng_count.copy_to(other.peng_count)
	peng_speed.copy_to(other.peng_speed)
	peng_carry.copy_to(other.peng_carry)


func _on_upgrade_tier_pressed():
	if do_gold_upgrade(upgrade_tier):
		on_upgrade_tier.emit()


func _on_peng_count_pressed():
	if do_coin_upgrade(peng_count):
		on_upgrade_peng_count.emit()

func _on_peng_speed_pressed():
	if do_coin_upgrade(peng_speed):
		on_upgrade_peng_speed.emit()

func _on_peng_carry_pressed():
	if do_coin_upgrade(peng_carry):
		on_upgrade_peng_carry.emit()


func save():
	var ret = super()
	ret['peng_count'] = peng_count.level
	ret['peng_speed'] = peng_speed.level
	ret['peng_carry'] = peng_carry.level
	
	return ret

func on_load(data : Dictionary):
	super(data)
	peng_count.level = data['peng_count']
	peng_speed.level = data['peng_speed']
	peng_carry.level = data['peng_carry']
