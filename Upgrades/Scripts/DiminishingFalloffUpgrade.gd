extends AbstractUpgrade
class_name ReciprocalUpgrade

@export var max_value : float = 1
@export var coefficient : float = 1

func function(lvl : int):
    return 1./(coefficient * lvl + 1)

func calc_at(lvl : int):
    return base + (max_value - base) * function(lvl)