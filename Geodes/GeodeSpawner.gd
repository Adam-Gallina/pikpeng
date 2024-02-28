extends Node2D
class_name GeodeSpawner

@export var GeodeWidth = 20.
@export var RevealedRows = 20
@export var ColsPerBuilding = 12.
@export var RevealedCols = 24
var center = -1
var lowest = -1

@export var RowsPerLayer : int = 20
@export var GeodeLayerBlend = 3

@onready var GeodeFactory = $GeodeFactory
@onready var GoldGeodeFactory = $GoldGeodeFactory
@export var MinGoldLayer : int = 15
@onready var GoldGeodeChance : AbstractUpgrade = $GoldSpawnChance

@onready var size = GeodeWidth / 100

var geodes = []
var geode_ends = []
var targets = []
@onready var highest_row = 0

func spawn(missing_left = [], missing_right = []):
	var rng = RandomNumberGenerator.new()

	if missing_left.size() == 0:
		for i in range((Constants.BuildingController.count_left() + 1) * ColsPerBuilding + RevealedCols): missing_left.append(-1)
	if missing_right.size() == 0:
		for i in range((Constants.BuildingController.count_right() + 1) * ColsPerBuilding + RevealedCols + 1): missing_right.append(-1)
	
	lowest = 0
	for i in missing_left: if i > lowest: lowest = i
	for i in missing_right: if i > lowest: lowest = i
	
	geodes = []
	geode_ends = []
	for x in range(-missing_left.size(), 0):
		var g = spawn_col(rng, x, missing_left[x + missing_left.size()])
		geodes.append(g[0])
		geode_ends.append(g[1])
	for x in range(missing_right.size()):
		var g = spawn_col(rng, x, missing_right[x])
		geodes.append(g[0])
		geode_ends.append(g[1])

	center = missing_left.size()
	for i in range(missing_left.size() + missing_right.size()):
		targets.append(null)

	# Update geode sprites
	for i in range(missing_left.size()):
		var g = geodes[i]
		for y in range((missing_left[i] + 1) if missing_left[i] != -1 else 1):
			if g == null:
				print('found null l geode at ', i, ' ', y)
				continue
			g.update_img()
			g = g.next
	for i in range(missing_left.size(), missing_left.size() + missing_right.size()):
		var g = geodes[i]
		for y in range((missing_right[i - missing_left.size()] + 1) if missing_right[i - missing_left.size()] != -1 else 1):
			if g == null:
				print('found null r geode at ', i, ' ', y)
				continue
			g.update_img()
			g = g.next

func get_layer_geode(rng : RandomNumberGenerator, y : int):
	var d : int = y / RowsPerLayer

	var f = GeodeFactory
	if y >= MinGoldLayer-1 and rng.randf() <= GoldGeodeChance.calc_at(d):
		f = GoldGeodeFactory

	# Blend with next layer
	var edge_offset = float(RowsPerLayer * (d+1) - y)
	#print(y, ' ', d, ' ', edge_offset)
	if edge_offset < GeodeLayerBlend and rng.randf() >= edge_offset / 2 / GeodeLayerBlend:
		d += 1

	return f.generate(rng, d)

func place_geode(geode : Node2D, pos : Vector2i):
	var dx = GeodeWidth
	var dy = dx
	#var start_x = -(GeodeColCount / 2) * GeodeWidth + dx / 2

	geode.scale = Vector2(size, size)
	#g.position = Vector2(start_x + dx * pos.x, dy / 2 + dy * pos.y)
	geode.position = Vector2(dx * pos.x, dy / 2 + dy * pos.y)
	geode.place(self, pos)

	add_child(geode)

# Returns the top and bottom geodes in an array
func spawn_col(rng : RandomNumberGenerator, x : int, missing : int):
	var s = null
	var g
	for y in range(lowest + RevealedRows):
		if y < missing:
			continue
		
		rng.seed = UserData.RNG_SEED + int('%d%d' % [x, y])

		var n = get_layer_geode(rng, y)
		place_geode(n, Vector2i(x, y))

		if s == null: s = n
		else: g.next = n
		g = n

	return [s, g]

func add_row(rng : RandomNumberGenerator):
	var y = geode_ends[0].pos.y + 1
	for x in range(geodes.size()):
		rng.seed = UserData.RNG_SEED + int('%d%d' % [x-center, y])
		var n = get_layer_geode(rng, y)
		place_geode(n, Vector2i(x-center, y))

		geode_ends[x].next = n
		geode_ends[x] = n


func geode_available():
	return targets.count(null) != 0

func get_closest_geode(pos : Vector2, is_available = true):
	if targets.count(null) == 0:
		printerr('No geodes available for penguin to mine')
		return null

	var t = null
	var dist = INF
	for i in range(targets.size()):
		if targets[i] != null and is_available:
			continue
		if geodes[i] == null:
			continue

		var d = geodes[i].global_position.distance_to(pos)
		if d < dist:
			t = i
			dist = d

	if t == null:
		printerr('Could not find geode for penguin to mine')
		return null

	return geodes[t]
	
func set_target(geode, peng):
	targets[geodes.find(geode)] = peng

func get_geode(pos : Vector2i):
	pos.x += center
	if pos.x < 0 or pos.x >= geodes.size() or pos.y < 0:
		return null

	var g = geodes[pos.x]
	if g == null:
		return null

	if g.pos.y > pos.y:
		return null

	while g.pos.y < pos.y:
		g = g.next
	return g

func get_closest_column(pos : Vector2, is_available = true):
	var t = null
	var dist = INF
	for i in range(targets.size()):
		if targets[i] != null and is_available:
			continue
		if geodes[i] == null:
			continue

		var d = abs(geodes[i].global_position.x - pos.x)
		if d < dist:
			t = i
			dist = d

	return geodes[t]

func remove_geode(geode):
	geodes[center + geode.pos.x] = geode.next
	targets[center + geode.pos.x] = null
	geode.queue_free()

	geodes[center + geode.pos.x].update_img()

	var g = get_geode(geode.pos + Vector2i(-1, 0))
	if g: g.update_img()
		
	g = get_geode(geode.pos + Vector2i(1, 0))
	if g: g.update_img()

	if geode.pos.y + 1 > lowest:
		lowest = geode.pos.y + 1
		add_row(RandomNumberGenerator.new())

func to_coord(pos : Vector2i):
	return global_position + Vector2(pos.x * GeodeWidth, pos.y * GeodeWidth)


func _on_buildings_building_created(building_type, dir):
	if building_type == Constants.BUILDING.CHUTE: return
	
	var rng = RandomNumberGenerator.new()

	if dir == -1:
		for i in range(ColsPerBuilding):
			var g = spawn_col(rng, geodes[0].pos.x - 1, -1)
			geodes.insert(0, g[0])
			geode_ends.insert(0, g[1])
			targets.insert(0, null)
			center += 1
		for x in range(ColsPerBuilding+1): geodes[x].update_img()
		var g = geodes[ColsPerBuilding-1]
		for y in range(geodes[ColsPerBuilding].pos.y):
			g.update_img()
			g = g.next
	else:
		for i in range(ColsPerBuilding):
			var g = spawn_col(rng, geodes[-1].pos.x + 1, -1)
			geodes.append(g[0])
			geode_ends.append(g[1])
			targets.append(null)
		for x in range(geodes.size()-ColsPerBuilding-1, geodes.size()): geodes[x].update_img()
		var g = geodes[geodes.size()-ColsPerBuilding]
		for y in range(geodes[geodes.size()-ColsPerBuilding-1].pos.y):
			g.update_img()
			g = g.next


func get_save_data():
	var missing_left = []
	var missing_right = []
	for g in geodes:
		if g.pos.x < 0:
			missing_left.append(g.pos.y)
		else:
			missing_right.append(g.pos.y)
	
	return [missing_left, missing_right]
