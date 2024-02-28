extends Node2D

func _ready():
	Constants.set_main(self)

	$Camera2D/ContButton.disabled = not UserData.save_available()
	$Camera2D/NewGameWarning.hide()

	var m = [1, 2, 3, 3, 2, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
	for _i in range(Constants.GeodeSpawner.ColsPerBuilding + Constants.GeodeSpawner.RevealedCols - m.size()): m.insert(0, 0)
	Constants.GeodeSpawner.spawn(m, [])
	
	var c = $Buildings/Chute
	c.get_parent().remove_child(c)
	Constants.BuildingController.append_chute(c, c.position)
	var g = $Buildings/GeodeMine
	g.get_parent().remove_child(g)
	Constants.BuildingController.append_mine(g, g.position)


func new_game():
	if UserData.save_available():
		$Camera2D/NewGameWarning.show()
	else:
		load_game()

func restart_game():
	if not UserData.reset_data():
		$Camera2D/NewGameWarning.show()
		$Camera2D/NewGameWarning/Label.text = 'Error: Could not delete old save'
	else:
		load_game()

func load_game():
	queue_free()
	get_tree().root.add_child(load(Constants.GAME_PATH).instantiate())

func quit():
	get_tree().quit()
