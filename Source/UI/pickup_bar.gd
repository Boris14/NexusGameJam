extends Panel

const Player1Texture = preload("res://Assets/background, UI-UX, assets/glasses pickup/pickup bar.png")
const Player2Texture = preload("res://Assets/second character/blue_slider.svg")

@export var indicator_speed = 160

var _max_indicator_x = 0
var _indicator_direction = 1
var is_indicator_moving = true
# Picked value indicates how far from the center the indicator is. [0; 1]
var _picked_value = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	_max_indicator_x = $Background.size.x - $Indicator.size.x
	_indicator_direction = 1 
	is_indicator_moving = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_indicator_moving or not visible:
		return
	
	# I'm a genious
	var speed_mult = cos(remap($Indicator.position.x, 0, _max_indicator_x, -PI, PI)) + 2
	$Indicator.position.x += indicator_speed * speed_mult * _indicator_direction * delta
	if $Indicator.position.x >= _max_indicator_x and _indicator_direction > 0:
		_indicator_direction = -1
	elif $Indicator.position.x <= 0 and _indicator_direction < 0:
		_indicator_direction = 1
		
func stop_indicator():
	is_indicator_moving = false
	_picked_value = abs(remap($Indicator.position.x, 0, _max_indicator_x, -1, 1))
	return _picked_value
	
func set_is_player_1(is_player_1):
	if is_player_1:
		$Background.texture = Player1Texture
	else:
		$Background.texture = Player2Texture
	
