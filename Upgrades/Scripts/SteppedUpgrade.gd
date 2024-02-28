extends AbstractUpgrade

@export var step : int = 1
@export var upgrade : AbstractUpgrade

func calc_at(lvl : int):
    return upgrade.calc_at(lvl / step)