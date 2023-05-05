extends Control

const Player1Avatar = preload("res://Assets/SVG/avatar bordert.svg")
const Player2Avatar = preload("res://Assets/second character/avatar 2.svg")

var is_player_1 = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
	
func set_is_player_1(is_player_1):
	if is_player_1:
		$ReferenceRect/AvatarBox.texture = Player1Avatar
	else:
		$ReferenceRect/AvatarBox.texture = Player2Avatar

func set_heatlh_value(new_value):
	$ReferenceRect/Healthbar.value = new_value
	
func set_solve_progress(new_progress):
	$ReferenceRect/Solvebar.value = new_progress
