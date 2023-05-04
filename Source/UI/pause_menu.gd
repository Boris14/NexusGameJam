extends Panel


var _listen_for_input_delay = 0.5
var _time_active = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	_time_active = 0

func _process(delta):
	_time_active += delta
	if (Input.is_action_just_pressed("ui_cancel") and 
		visible and _time_active > _listen_for_input_delay):
		_time_active = 0
		get_tree().paused = false
		visible = false


func _on_resume_button_pressed():
	_time_active = 0
	get_tree().paused = false
	visible = false


func _on_quit_button_pressed():
	pass # Go to main menu
