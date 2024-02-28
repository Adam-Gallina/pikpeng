extends Control

@export var start_enabled : bool = true
var enabled : bool

func _ready():
	enabled = !start_enabled
	if start_enabled:
		_show()
	else:
		_hide()

func _show():
	if !enabled:
		$RichTextLabel.visible = true
		enabled = true
	
func _hide():
	if enabled:
		$RichTextLabel.visible = false
		enabled = false
