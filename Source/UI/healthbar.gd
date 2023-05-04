extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

func set_heatlh_value(new_value):
	$ReferenceRect/Healthbar.value = new_value
