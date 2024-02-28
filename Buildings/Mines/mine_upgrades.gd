extends BuildingUpgrades
class_name MineUpgrades

# T1
signal on_upgrade_peng_mine_strength
@export var peng_mine_strength : AbstractUpgrade
signal on_upgrade_mine_storage
@export var mine_storage : AbstractUpgrade

# T2/3
signal on_upgrade_max_depth
@export var max_depth : AbstractUpgrade
signal on_upgrade_bucket_speed
@export var bucket_speed : AbstractUpgrade


func copy_to(other : BuildingUpgrades):
	if not other is MineUpgrades:
		printerr('Trying to copy non-mine to a mine')
		return

	super(other)

	peng_mine_strength.copy_to(other.peng_mine_strength)
	mine_storage.copy_to(other.mine_storage)
	max_depth.copy_to(other.max_depth)
	bucket_speed.copy_to(other.bucket_speed)


func _on_peng_mine_strength_pressed():
	if do_coin_upgrade(peng_mine_strength):
		on_upgrade_peng_mine_strength.emit()

func _on_mine_storage_pressed():
	if do_coin_upgrade(mine_storage):
		on_upgrade_mine_storage.emit()

func _on_max_depth_pressed():
	if do_coin_upgrade(max_depth):
		on_upgrade_max_depth.emit()

func _on_bucket_speed_pressed():
	if do_coin_upgrade(bucket_speed):
		on_upgrade_bucket_speed.emit()


func save():
	var data = super()

	data['peng_mine_strength'] = peng_mine_strength.level
	data['mine_storage'] = mine_storage.level
	data['max_depth'] = max_depth.level
	data['bucket_speed'] = bucket_speed.level

	return data

func on_load(data : Dictionary):
	super(data)

	peng_mine_strength.level = data['peng_mine_strength']
	mine_storage.level = data['mine_storage']
	max_depth.level = data['max_depth']
	bucket_speed.level = data['bucket_speed']
