extends Control

const Healthbar = preload("res://Source/UI/healthbar.gd")

@export var round_time = 70

var _time_left = 0
var _player_1_healthbar : Healthbar
var _player_2_healthbar : Healthbar
var _seconds_label : Label
var _minutes_label : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_1_healthbar = $Player1Healthbar as Healthbar
	_player_2_healthbar = $Player2Healthbar as Healthbar
	_seconds_label = $TimerTexture/SecondsLabel as Label
	_minutes_label = $TimerTexture/MinutesLabel as Label
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
		$RoundTimer.stop()


func _on_player_health_changed(is_player_1, new_health, max_health):
	if is_player_1:	
		_player_1_healthbar.set_heatlh_value(new_health / max_health * 100)
	else:
		_player_2_healthbar.set_heatlh_value(new_health / max_health * 100)
