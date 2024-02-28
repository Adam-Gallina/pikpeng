extends AbstractBuilding
class_name Chute

signal coin_percent(amount, max_amount)

@export var peng_path_offset : float
@export var peng_path_width : float

@export var saw_anims : Array[AnimationPlayer]

var curr_processed = 0

func _ready():
	super()

	coin_percent.emit(0, 1)

func check_end_idle():
	if Constants.BuildingController.Mines.size() == 0:
		return false

	for m in Constants.BuildingController.Mines:
		if m.curr_stored.size() > 0 and m not in Constants.BuildingController.selected_mines:
			return true

	return false

func _process(delta):
	super(delta)
	
	if curr_stored.size() > 0:
		curr_processed += calc_process_speed() * delta
		while curr_stored.size() > 0 and curr_processed >= curr_stored[0].strength:
			curr_processed -= curr_stored[0].strength
			extract_geode(curr_stored.pop_front())
		coin_percent.emit(curr_processed, 1 if curr_stored.size() == 0 else curr_stored[0].strength)
	else:
		curr_processed = 0

	update_anims()

func extract_geode(geode):

	if geode.resource_type == Constants.RESOURCE.COIN:
		spawn_anim(coin_anim, geode.extract(calc_coin_value_mod()))
	elif geode.resource_type == Constants.RESOURCE.GOLD:
		spawn_anim(gold_anim, geode.extract(calc_gold_value_mod()))
	else:
		printerr('Cannot spawn anim for %d' % geode.resource_type)
	geode.queue_free()

func update_anims():
	for i in range(saw_anims.size()):
		if curr_stored.size() > 0 and not saw_anims[i].is_playing():
			saw_anims[i].play('spin' if i % 2 == 0 else 'spin_back')
		elif curr_stored.size() == 0 and saw_anims[i].is_playing():
			saw_anims[i].pause()


func request_new_target(peng, last_target):
	if peng.can_carry():
		var m = Constants.BuildingController.get_mine(peng.get_pos(), last_target)
		if m != null:
			peng.set_target(m, m.withdraw_point.global_position, Constants.INTERACTION.WITHDRAW)
			return
	
	if peng.curr_carry.size() != 0:
		peng.set_target(self, deposit_point.global_position, Constants.INTERACTION.DEPOSIT)
	else:
		add_idle(peng)


func calc_process_speed():
	return upgrades.process_speed.calc()

func calc_coin_value_mod():
	return (upgrades.sell_value.calc() + Constants.GoldUpgrades.coin_value.calc())

func calc_gold_value_mod():
	return upgrades.sell_value.calc()


func copy_to_building(new_building : AbstractBuilding):
	super(new_building)

	new_building.curr_processed = curr_processed

	Constants.BuildingController.clear_selected_mines()


func on_load(data : Dictionary):
	super(data)

	Constants.BuildingController.append_chute(self, Vector2(data['pos_x'], data['pos_y']))
