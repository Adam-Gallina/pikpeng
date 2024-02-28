extends AbstractUpgrade

@export var step : float

func calc_at(lvl : int):
    return base + step * lvl