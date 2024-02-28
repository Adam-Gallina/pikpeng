extends Chute_GoldProducer
class_name Chute_Overclock
 
var overclocked = false

func calc_process_speed():
	var v = super()
	return v if not overclocked else v * upgrades.clock_speed.calc()

func calc_coin_value_mod():
	var v = super()
	return v if not overclocked else v * upgrades.clock_value.calc()


func copy_to_building(new_building : AbstractBuilding):
	super(new_building)

	new_building.overclocked = overclocked

func _on_overclock_toggle_toggled(button_pressed:bool):
	overclocked = button_pressed


func save():
	var data = super()

	data['overclocked'] = overclocked

	return data

func on_load(data : Dictionary):
	overclocked = data['overclocked']
	$OverclockToggle.button_pressed = overclocked
	
	super(data)

