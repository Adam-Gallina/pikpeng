extends AbstractUpgrade

@export var coefficient : float = 1
@export var power : float = 2

func calc_at(lvl : int):
    return (coefficient * lvl) ** power + base