extends Control

@export var round_time = 60

var _time_left = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_time_left = round_time
	$RoundTimer.start(1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_round_timer_timeout():
	_time_left -= 1
	$RoundTimeLabel.text = str(_time_left)
	if _time_left <= 0:
		$RoundTimer.stop()


func _on_player_health_changed(is_player_1, new_health, max_health):
	if is_player_1:	
		$Player1HealthBar.value = new_health / max_health * 100
	else:
		$Player2HealthBar.value = new_health / max_health * 100
