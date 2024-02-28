extends GeodeMine
class_name GeodeMine_PeriodicDeposit

@export var BucketNode : Node2D

var curr_queued : Array[Geode] = []
var bucket_pos : Array[float] = []
var bucket_stored : Array[Array] = []

func spawn():
	deposit_point.global_position = get_max_valid_depth_pos()
	super()


func _process(delta):
	super(delta)

	deposit_point.global_position = get_max_valid_depth_pos()

	if curr_queued.size() >= calc_max_bucket_storage():
		start_bucket_anim()

	if bucket_pos.size() > 0:
		update_buckets(delta)
	update_bucket_image()


func deposit(geodes:Array[Geode]):
	if not spawned:
		super(geodes)
	else:
		curr_queued.append_array(geodes)


func start_bucket_anim():
	if not can_spawn_bucket():
		return

	var p = get_max_valid_depth_pos()
	bucket_pos.append(p.y)
	bucket_stored.append([])
	while bucket_stored[-1].size() < calc_max_bucket_storage() and curr_queued.size() > 0:
		bucket_stored[-1].append(curr_queued.pop_front())

func can_spawn_bucket():
	return bucket_pos.size() == 0

func update_buckets(delta):
	var d = calc_bucket_speed() * delta
	for i in range(bucket_pos.size(), 0, -1):
		bucket_pos[i-1] -= d

		if bucket_pos[i-1] <= 0:
			bucket_pos.pop_at(i-1)
			var geodes = bucket_stored.pop_at(i-1)
			curr_stored.append_array(geodes)
			var arr : Array[Geode] = []
			for g in geodes: arr.append(g)
			on_deposit(arr)

			
func update_bucket_image():
	$Inside/LeftChain.DoAnim = bucket_pos.size() > 0
	$Inside/RightChain.DoAnim = bucket_pos.size() > 0

	if BucketNode != null:
		if bucket_pos.size() > 0:
			BucketNode.position = Vector2(0, bucket_pos[0])
		BucketNode.visible = bucket_pos.size() > 0


func calc_max_depth():
	return upgrades.max_depth.calc() * Constants.GeodeSpawner.GeodeWidth

func get_max_valid_depth_pos():
	var g = Constants.GeodeSpawner.get_closest_column(global_position, false)

	var pos = g.global_position - Vector2(0, Constants.GeodeSpawner.GeodeWidth)
	var depth = calc_max_depth()

	if global_position.distance_to(pos) > depth:
		pos = global_position + Vector2.DOWN * depth
	
	return pos

func calc_bucket_speed():
	return upgrades.bucket_speed.calc() + Constants.GoldUpgrades.global_bucket_speed.calc()

func calc_max_bucket_storage():
	return calc_max_storage() / 4


func storage_full():
	var buckets = 0
	for b in bucket_stored:
		buckets += b.size()

	return curr_stored.size() + curr_queued.size() + buckets >= calc_max_storage()


func save():
	var ret = super()

	var data = []

	for i in curr_queued:
		data.append(i.save())
	ret['curr_queued'] = data

	return ret

func on_load(data : Dictionary):
	super(data)

	for i in data['curr_queued']:
		var item = load(i["filename"]).instantiate()
		item.on_load(i)
		curr_queued.append(item)

func on_quit():
	super()

	for i in bucket_stored:
		curr_stored.append_array(i)
	bucket_pos.clear()
	bucket_stored.clear()
