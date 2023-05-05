extends Control


var _input_blocked = false
var _curr_image = 0
var _images = []

# Called when the node enters the scene tree for the first time.
func _ready():
	_images = [$Image1, $Image2, $Image3]
	_images[0].visible = true
	_images[1].visible = false
	_images[2].visible = false
	_curr_image = 0
	_input_blocked = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not _input_blocked and Input.is_anything_pressed():
		_input_blocked = true
		_button_pressed()
		get_tree().create_timer(1).timeout.connect(_release_input)
		
func _release_input():
	_input_blocked = false


func _button_pressed():
	if _curr_image >= 2:
		get_tree().change_scene_to_file("res://Scenes/UI/MainMenu.tscn")
	else:
		_curr_image += 1
		_images[_curr_image].visible = true
