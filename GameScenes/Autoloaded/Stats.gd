extends Node

var total_coins : int = 1000
var total_gold : int = 100

#func _unhandled_input(event):
#    if event is InputEventKey:
#        if event.pressed and not event.echo:
#            if event.keycode == KEY_EQUAL:
#                total_coins += 1000
#            elif event.keycode == KEY_MINUS:
#                total_gold += 100

func can_upgrade(price:int, do_upgrade=false):
    if total_coins >= price:
        if do_upgrade: total_coins -= price
        return true
    return false

func can_gold_upgrade(price:int, do_upgrade=false):
    if total_gold >= price:
        if do_upgrade: total_gold -= price
        return true
    return false