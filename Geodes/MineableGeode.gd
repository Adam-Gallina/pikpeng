extends AbstractStorage

signal on_building_replaced(old_building:AbstractBuilding, new_building:AbstractBuilding)

## The time for a lvl 1 peng to mine this geode
@export var strength = 2

var spawner
var pos : Vector2i
var next

@onready var left_img = $BorderLeft
@onready var right_img = $BorderRight
@onready var top_img = $BorderTop

func _ready():
	super()

	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.frame = randi() % 16

func place(new_spawner, new_pos):
	spawner = new_spawner
	pos = new_pos

func set_color(col : Color):
	modulate = col
func set_strength(mine_strength):
	strength = mine_strength
func set_geode_strength(geode_strength):
	$GeodeVals.strength = geode_strength
func set_value(value):
	$GeodeVals.value = value
func set_resource_type(resource_type):
	$GeodeVals.resource_type = resource_type

func withdraw(amount:int):
	var ret = super(amount)

	if curr_stored.size() <= 0:
		spawner.remove_geode(self)

	return ret

func update_img():
	left_img.visible = spawner.get_geode(pos + Vector2i(-1, 0)) == null
	right_img.visible = spawner.get_geode(pos + Vector2i(1, 0)) == null
	top_img.visible = spawner.get_geode(pos + Vector2i(0, -1)) == null
