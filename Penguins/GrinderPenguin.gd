extends AbstractPenguin

func set_target(t:AbstractStorage, t_pos:Vector2, interaction:int):
	super(t, t_pos, interaction)
	if t == null:
		return

	var y = building.peng_path_offset
	y += randf() * building.peng_path_width - building.peng_path_width / 2
	var sx = curve.get_point_position(0).x
	var dx = t.global_position.x - sx

	curve.add_point(Vector2(sx + dx * .1, y), Vector2(), Vector2(), 1)
	curve.add_point(Vector2(sx + dx * .9, y), Vector2(), Vector2(), 2)

func collect_target(anim = 'interact'):
	super(anim)
	Constants.BuildingController.on_withdraw_mine(target)
