extends CanvasLayer

var UiState := {
	UpgradePanel = false
}
signal set_upgrade_panel(show_panel:bool)

@onready var save_anim = $LoadAnim
@onready var save_timer = $LoadAnim/HideAnim

func toggle_upgrade_panel():
	UiState.UpgradePanel = !UiState.UpgradePanel
	set_upgrade_panel.emit(UiState.UpgradePanel)


func _ready():
	$PauseMenu.hide()
	save_anim.hide()
	$LoadAnim.play()

	UserData.save_start.connect(save_anim.show)
	UserData.save_end.connect(save_timer.start)
	
	$Debug/Button2.disabled = UserData.save_available()

func update_ui():
	$Sign/PencoinTextureRect/Label.text = str(Stats.total_coins)
	$Sign/PengoldTextureRect/Label.text = str(Stats.total_gold)

	$ReturnToSurface.visible = Constants.MainCam.position.y > 350

	$UpgradeUI.update_ui()


func _on_return_to_surface_pressed():
	Constants.MainCam.set_focus(Constants.MainCam.get_closest_building())

func btn_save():
	UserData.save_all_data()
	
func btn_main_menu():
	UserData.save_and_exit()

	await save_timer.timeout
	Constants.Main.queue_free()
	get_tree().root.add_child(load(Constants.MAIN_MENU_PATH).instantiate())

func btn_quit():
	UserData.save_and_exit()

	await save_timer.timeout
	get_tree().quit()


func btn_reset():
	print('reset successful: %s' % ('yes' if UserData.reset_data() else 'no'))

func btn_load():
	print('loaded')
	UserData.load_all_data()

func btn_restart():
	print('restarted')
	get_parent().get_parent().get_tree().reload_current_scene()
