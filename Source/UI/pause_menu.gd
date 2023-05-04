extends Panel


# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		unpause()


func pause():
	visible = true
	get_tree().paused = true
	
	
func unpause():
	visible = false
	get_tree().paused = false


func _on_resume_button_pressed():
	unpause()


func _on_restart_button_pressed():
	unpause()
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	unpause()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

