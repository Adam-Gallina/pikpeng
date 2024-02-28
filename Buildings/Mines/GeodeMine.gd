extends AbstractBuilding
class_name GeodeMine

func spawn_peng(peng):
	super(peng)
	peng.set_size(Constants.GeodeSpawner.size)

func check_end_idle():
	if storage_full():
		return false

	return Constants.GeodeSpawner.geode_available()

func _process(delta):
	super(delta)

	var ms = calc_max_storage()
	if curr_stored.size() >= ms:
		storage_filled.emit(self)

func on_deposit(geodes:Array[Geode]):
	super(geodes)

	var total = 0
	for g in geodes:
		total += g.value * calc_geode_mod()
	Stats.total_coins += total

	if total != 0:
		spawn_anim(coin_anim, total)


func request_new_target(peng, _last_target):
	if peng.can_carry():
		var g = Constants.GeodeSpawner.get_closest_geode(peng.get_pos())
		Constants.GeodeSpawner.set_target(g, peng)
		peng.set_target(g, g.global_position, Constants.INTERACTION.WITHDRAW)
	else:
		if storage_full():
			add_idle(peng)
		else:
			peng.set_target(self, deposit_point.global_position, Constants.INTERACTION.DEPOSIT)


func calc_weight(pos:Vector2):
	if curr_stored.size() < 1:
		return 0

	var percent_dist = 1 - position.distance_to(pos) / Constants.BuildingController.calc_map_size()
	return float(curr_stored.size()) / calc_max_storage() + percent_dist / 2


func calc_peng_mine_strength():
	return upgrades.peng_mine_strength.calc()

func on_upgrade_max_storage():
	storage_changed.emit(curr_stored.size(), calc_max_storage())

func calc_max_storage():
	return upgrades.mine_storage.calc()

func calc_geode_mod():
	return 1 + Constants.GoldUpgrades.coin_value.calc()


func on_load(data : Dictionary):
	super(data)

	Constants.BuildingController.append_mine(self, Vector2(data['pos_x'], data['pos_y']))
