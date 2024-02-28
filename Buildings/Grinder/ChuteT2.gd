extends Chute
class_name Chute_GoldProducer

signal gold_percent(amount, max_amount)

@export var geodes_per_gold = 1000
var curr_gold = 0

func _ready():
    super()

    gold_percent.emit(0, 1)

func extract_geode(geode):
    super(geode)

    curr_gold += calc_gold_efficiency()
    while curr_gold >= geodes_per_gold:
        curr_gold -= geodes_per_gold
        Stats.total_gold += int(calc_gold_value_mod())
        spawn_anim(gold_anim, int(calc_gold_value_mod()))
    gold_percent.emit(curr_gold, geodes_per_gold)


func calc_gold_efficiency():
    return upgrades.gold_efficiency.calc()


func copy_to_building(new_building : AbstractBuilding):
    super(new_building)

    new_building.curr_gold = curr_gold


func save():
    var data = super()

    data['curr_gold'] = curr_gold

    return data

func on_load(data : Dictionary):
    curr_gold = data['curr_gold']

    super(data)
    
    gold_percent.emit(curr_gold, geodes_per_gold)