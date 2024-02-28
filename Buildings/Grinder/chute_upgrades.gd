extends BuildingUpgrades
class_name ChuteUpgrades

# T1
signal on_upgrade_process_speed
@export var process_speed : AbstractUpgrade

# T2
signal on_upgrade_sell_value
@export var sell_value : AbstractUpgrade
signal on_upgrade_gold_efficiency
@export var gold_efficiency : AbstractUpgrade

# T3
signal on_upgrade_overclock
@export var clock_speed : AbstractUpgrade
@export var clock_value : AbstractUpgrade


func copy_to(other : BuildingUpgrades):
    if not other is ChuteUpgrades:
        printerr('Trying to copy non-chute to a chute')
        return

    super(other)

    process_speed.copy_to(other.process_speed)
    sell_value.copy_to(other.sell_value)
    gold_efficiency.copy_to(other.gold_efficiency)
    clock_speed.copy_to(other.clock_speed)
    clock_value.copy_to(other.clock_value)


func _on_process_speed_pressed():
    if do_coin_upgrade(process_speed):
        on_upgrade_process_speed.emit()

func _on_sell_value_pressed():
    if do_coin_upgrade(sell_value):
        on_upgrade_sell_value.emit()

func _on_gold_efficiency_pressed():
    if do_coin_upgrade(gold_efficiency):
        on_upgrade_gold_efficiency.emit()

func _on_overclock_pressed():
    if do_coin_upgrade(clock_speed):
        clock_value.level += 1
        on_upgrade_overclock.emit()


func save():
    var data : Dictionary = super()

    data['process_speed'] = process_speed.level
    data['sell_value'] = sell_value.level
    data['gold_efficiency'] = gold_efficiency.level
    data['clock_speed'] = clock_speed.level
    data['clock_value'] = clock_value.level

    return data

func on_load(data : Dictionary):
    super(data)

    process_speed.level = data['process_speed']
    sell_value.level = data['sell_value']
    gold_efficiency.level = data['gold_efficiency']
    clock_speed.level = data['clock_speed']
    clock_value.level = data['clock_value']
