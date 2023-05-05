extends Control

const GameScene = preload("res://Scenes/Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_play_button_pressed():
	get_tree().change_scene_to_packed(GameScene)


func _on_how_to_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/HowToPlay.tscn")


func _on_quit_button_pressed():
	get_tree().quit()


func _on_play_button_mouse_entered():
	$BackgroundNormal.visible = false


func _on_how_to_button_mouse_entered():
	$BackgroundNormal.visible = false


func _on_quit_button_mouse_entered():
	$BackgroundNormal.visible = false


func _on_play_button_mouse_exited():
	$BackgroundNormal.visible = true


func _on_how_to_button_mouse_exited():
	$BackgroundNormal.visible = true


func _on_quit_button_mouse_exited():
	$BackgroundNormal.visible = true
