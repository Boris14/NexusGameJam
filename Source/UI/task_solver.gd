extends Panel

const TaskLineScene = preload("res://Scenes/UI/TaskLine.tscn")

@export var initial_line_spawn_interval = 2
@export var initial_line_speed = 60
@export var line_spawn_increase_rate = 0.02
@export var line_speed_increase_rate = 0.1
@export var hitbox_error = 13

var _rand = RandomNumberGenerator.new()
var _slides = []
var _slide_actions = []
var _lines = []
var _line_spawn_interval
var _line_speed
var _hitbox_x
var _is_player_1


# Called when the node enters the scene tree for the first time.
func _ready():
	_slides = [$VBoxContainer/Slide1, $VBoxContainer/Slide2, $VBoxContainer/Slide3]
	_hitbox_x = _slides[0].find_child("HitBox").position.x
	visible = false 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible:
		return 
	
	for i in len(_slide_actions):
		if Input.is_action_just_pressed(_slide_actions[i]):
			for line in _lines:
				if (line.owner == _slides[i] and
					abs(line.position.x - _hitbox_x) <= hitbox_error):
					_lines.erase(line)
					line.queue_free()
					
	for line in _lines:
		line.position.x -= delta * _line_speed
		if line.position.x <= 0:
			_lines.erase(line)
			line.queue_free()
	_line_spawn_interval -= delta * line_spawn_increase_rate
	_line_speed += delta * line_speed_increase_rate
	
	
func _spawn_line():
	if not visible:
		return

	var line = TaskLineScene.instantiate() as Control
	line.set_anchors_preset(Control.PRESET_CENTER_RIGHT, false)
	var index = _rand.randi_range(0, _slides.size() - 1)
	_slides[index].add_child(line)
	line.owner = _slides[index]
	_lines.append(line)		
	get_tree().create_timer(_line_spawn_interval).timeout.connect(_spawn_line)
	
func set_is_player_1(in_is_player_1):
	_is_player_1 = in_is_player_1
	# Add the button actions
	_slide_actions.append(str("player_" + ("1" if _is_player_1 else "2") + "_punch"))
	_slide_actions.append(str("player_" + ("1" if _is_player_1 else "2") + "_kick"))
	_slide_actions.append(str("player_" + ("1" if _is_player_1 else "2") + "_solve"))
	for i in len(_slides):
		# Set the correct labels 
		var labelName = str("Player" + ("1" if _is_player_1 else "2") + "Label")
		(_slides[i].find_child(labelName, false) as Label).text = InputMap.action_get_events(_slide_actions[i])[0].as_text()[0]
		var otherLabelName = str("Player" + ("2" if _is_player_1 else "1") + "Label")
		_slides[i].find_child(otherLabelName, false).visible = false

func start_solving():
	visible = true
	_line_spawn_interval = initial_line_spawn_interval
	_line_speed = initial_line_speed
	get_tree().create_timer(_line_spawn_interval).timeout.connect(_spawn_line)
	
func stop_solving():
	for node in _lines:
		node.queue_free()
		_lines.erase(node)
	visible = false
