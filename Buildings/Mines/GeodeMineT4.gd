extends GeodeMine_ContinuousDeposit
class_name GeodeMine_SelfMine


func update_ui():
	super()
    
	if !focused: return
	#max_depth.set_text()