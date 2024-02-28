extends Node2D

@export var reset_data = false
@export var skip_tut = false

@export var start_coins = 1000
@export var start_gold = 100

func _ready():
	Constants.set_main(self)

	if reset_data:
		if not UserData.reset_data():
			printerr('Could not reset data, last save will be used')

	if not UserData.save_available():
		Constants.GeodeSpawner.spawn()
		Constants.BuildingController.add_chute()
		Stats.total_coins = start_coins
		Stats.total_gold = start_gold
		if not skip_tut:
			$Tutorial.start_tutorial()
	else:
		UserData.load_all_data()
	$Camera2D.show_closest_building()

func _process(_delta):
	$Camera2D/MainUI.update_ui()
	Constants.BuildingController.update_ui()


func _on_autosave_timeout():
	UserData.save_all_data()
