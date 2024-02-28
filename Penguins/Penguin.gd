extends Path2D
class_name AbstractPenguin

signal change_anim(anim:String)
signal change_dir(dir:int)

var curr_carry : Array[Geode] = []
var target
var target_pos = null
var at_target = false
var target_interaction = -1

var building = null
@onready var path = $PathFollow2D

func _ready():
	path.progress = 0

func set_source(source):
	self.building = source

func set_size(s):
	path.scale = Vector2(s, s)

func get_pos():
	return path.global_position


func _physics_process(delta):
	if target == null or at_target:
		return

	path.progress += calc_move_speed() * delta
	if path.progress_ratio == 1:
		reached_target()


func add_items(items : Array[Geode]):
	curr_carry.append_array(items)
	return can_carry()

func reached_target():
	at_target = true
	if target_interaction == Constants.INTERACTION.DEPOSIT:
		deposit_target()
	elif target_interaction == Constants.INTERACTION.WITHDRAW:
		collect_target()
	else:
		printerr('Cannot interact with target: Unknown interaction type %d' % target_interaction)

func set_idle():
	change_anim.emit('idle_carry' if curr_carry.size() > 0 else 'idle')

func set_target(t:AbstractStorage, t_pos:Vector2, interaction:int):
	curve.clear_points()
	path.progress = 0
	if target_pos == null:
		curve.add_point(building.deposit_point.global_position)
	else:
		curve.add_point(target_pos)

	target_pos = t_pos
	curve.add_point(t_pos)

	if target != null:
		target.on_building_replaced.disconnect(_on_building_replaced)
	t.on_building_replaced.connect(_on_building_replaced)

	target = t
	at_target = false
	target_interaction = interaction
		
	change_anim.emit('walk_carry' if curr_carry.size() > 0 else 'walk')
	change_dir.emit(-1 if target.global_position.x < get_pos().x else 1)

func collect_target(anim = 'interact'):
	change_anim.emit(anim)
	# Start collection anim
	$GatherTimer.start()
	await $GatherTimer.timeout

	if target != null:
		add_items(target.withdraw(calc_carry_max() - curr_carry.size()))
	else:
		printerr('Tried to collect from target, but it doesn\'t exist anymore')
	building.request_new_target(self, target)

func deposit_target(anim = 'interact'):
	change_anim.emit(anim)
	# Start deposit anim
	$DepositTimer.start()
	await $DepositTimer.timeout

	if target != null:
		target.deposit(curr_carry)
		curr_carry = []
	else:
		printerr('Tried to deposit into target, but it doesn\'t exist anymore')

	building.request_new_target(self, target)


func can_carry():
	return curr_carry.size() < calc_carry_max()

func calc_carry_max():
	return building.calc_peng_carry()
	
func calc_move_speed():
	return building.calc_peng_speed()


func _on_building_replaced(old_building:AbstractBuilding, new_building:AbstractBuilding):
	if target != old_building: return

	target = new_building


func on_quit():
	building.deposit(curr_carry)
	curr_carry = []
