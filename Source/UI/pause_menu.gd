extends Panel


const click_sounds = [
	"res://Audio/Paper1.mp3",
	"res://Audio/Paper2.mp3",
	"res://Audio/Paper3.mp3",
]

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
	var sound = load(click_sounds[randi_range(0, click_sounds.size()) - 1])
	$ClickAudio.set_stream(sound)
	$ClickAudio.play()

func _on_restart_button_pressed():
	unpause()
	var sound = load(click_sounds[randi_range(0, click_sounds.size()) - 1])
	$ClickAudio.set_stream(sound)
	$ClickAudio.play()
	get_tree().reload_current_scene()


func _on_quit_button_pressed():
	unpause()
	var sound = load(click_sounds[randi_range(0, click_sounds.size()) - 1])
	$ClickAudio.set_stream(sound)
	$ClickAudio.play()
	get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")

