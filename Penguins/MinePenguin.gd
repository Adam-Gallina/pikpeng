extends AbstractPenguin


func collect_target(anim = 'mine'):
	$GatherTimer.wait_time = calc_geode_mine_duration(target)
	super(anim)


func calc_geode_mine_duration(geode):
	return geode.strength / building.calc_peng_mine_strength()
