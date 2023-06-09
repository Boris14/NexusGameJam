extends Control

const Healthbar = preload("res://Source/UI/healthbar.gd")

signal round_ended()

@export var round_time = 120
@export var player_1_color : Color
@export var player_2_color : Color

var _time_left = 0
var _player_1_healthbar : Healthbar
var _player_2_healthbar : Healthbar
var _seconds_label : Label
var _minutes_label : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_1_healthbar = $Player1Healthbar as Healthbar
	_player_1_healthbar.set_is_player_1(true)
	_player_2_healthbar = $Player2Healthbar as Healthbar
	_player_2_healthbar.set_is_player_1(false)
	_seconds_label = $TimerTexture/SecondsLabel as Label
	_minutes_label = $TimerTexture/MinutesLabel as Label
	$Player1Grade.visible = false
	$Player2Grade.visible = false
	$PlayAgainButton.visible = false
	_time_left = round_time
	_on_round_timer_timeout()
	$RoundTimer.start(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_round_timer_timeout():
	_time_left -= 1
	var seconds_value = _time_left % 60
	var minutes_value = _time_left / 60
	_seconds_label.text = str(seconds_value) if seconds_value > 9 else "0" + str(seconds_value)
	_minutes_label.text = str(minutes_value) if minutes_value > 9 else "0" + str(minutes_value)
	if _time_left <= 0:
		emit_signal("round_ended")
		$RoundTimer.stop()


func _on_player_health_changed(is_player_1, new_health, max_health):
	if is_player_1:	
		_player_1_healthbar.set_heatlh_value(new_health / max_health * 100)
	else:
		_player_2_healthbar.set_heatlh_value(new_health / max_health * 100)
		
		
func _on_player_solve_score_changed(is_player_1, new_score, max_score):
	if is_player_1:	
		_player_1_healthbar.set_solve_progress(float(new_score) / max_score * 100)
	else:
		_player_2_healthbar.set_solve_progress(float(new_score) / max_score * 100)

func _on_player_won(is_player_1):
	$PlayAgainButton/Label.label_settings.font_color = player_1_color if is_player_1 else player_2_color
	$PlayAgainButton.visible = true
	if is_player_1:
		$Player1Grade.visible = true
	else:
		$Player2Grade.visible = true


func _on_play_again_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/UI/TitleScreen.tscn")


func _on_play_again_button_button_down():
	$PlayAgainButton/Label.position.y -= 13


func _on_play_again_button_button_up():
	$PlayAgainButton/Label.position.y += 13
