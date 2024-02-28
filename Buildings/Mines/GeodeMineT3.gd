extends GeodeMine_PeriodicDeposit
class_name GeodeMine_ContinuousDeposit

@export var dist_between_buckets = 50

func update_bucket_image():
	$Inside/Column.DoAnim = bucket_pos.size() > 0


func can_spawn_bucket():
	return bucket_pos.size() == 0 or get_max_valid_depth_pos().y - bucket_pos[-1] >= dist_between_buckets

func calc_max_bucket_storage():
	return 1
