extends AbstractUpgrade

@export var steps : Array[float]
@export var upgrades : Array[AbstractUpgrade]

func _ready():
    if steps.size() != upgrades.size():
        printerr(get_parent(), ' Spliced upgrade has uneven steps to splices')

func calc_at(lvl : int):
    if upgrades.size() == 0:
        printerr('Trying to splice 0 upgrades together')
        return base
    elif upgrades.size() == 1:
        return upgrades[0].calc_at(lvl)

    var s = 0
    while lvl < steps[s]:
        if steps.size() == s + 1: break
        s += 1
        
    return upgrades[s].calc_at(lvl - steps[s])
