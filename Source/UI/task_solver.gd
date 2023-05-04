extends Panel

const TaskLineScene = preload("res://Scenes/UI/TaskLine.tscn")

const Player1WholeTexture = preload("res://Assets/SVG/guitar hero/whole thing.svg")
const Player2WholeTexture = preload("res://Assets/second character/the whole thing 2.svg")
const Player1LineTexture = preload("res://Assets/SVG/guitar hero/target.svg")
const Player2LineTexture = preload("res://Assets/second character/target 2.svg")


signal line_hit()
signal line_missed()

@export var initial_line_spawn_interval = 1
@export var initial_line_speed = 130
@export var min_line_spawn_interval = 1
@export var max_line_speed = 200
@export var hit_spawn_interval_decrease = 0.94
@export var hit_speed_increase = 1.12
@export var hitbox_error = 20

var _rand = RandomNumberGenerator.new()
var _slides = []
var _player_1_buttons = []
var _player_2_buttons = []
var _player_1_dashes = []
var _player_2_dashes = []
var _slide_actions = []
var _lines = []
var _line_spawn_interval
var _line_speed
var _hitbox_x
var _is_player_1


# Called when the node enters the scene tree for the first time.
func _ready():
	_slides = [$VBoxContainer/Slide1, $VBoxContainer/Slide2, $VBoxContainer/Slide3]
	for slide in _slides:
		_player_1_buttons.append(slide.find_child("Player1ButtonBox"))
		_player_2_buttons.append(slide.find_child("Player2ButtonBox"))
		_player_1_dashes.append(slide.find_child("Player1Dash"))
		_player_2_dashes.append(slide.find_child("Player2Dash"))

	_hitbox_x = _slides[0].find_child("HitBox").position.x
	visible = false 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible:
		return 
					
	for line in _lines:
		line.position.x -= delta * _line_speed
		if line.position.x <= 0:
			_lines.erase(line)
			line.queue_free()

	for i in len(_slide_actions):
		if Input.is_action_just_pressed(_slide_actions[i]):
			var hit = false
			for line in _lines:
				if (line.owner == _slides[i] and
					abs(line.position.x - _hitbox_x) <= hitbox_error):
					hit = true
					_lines.erase(line)
					line.queue_free()
					_line_speed = clamp(_line_speed * hit_speed_increase, 0, max_line_speed)
					_line_spawn_interval = clamp(_line_spawn_interval * hit_spawn_interval_decrease, min_line_spawn_interval, initial_line_spawn_interval)
					emit_signal("line_hit")
			if not hit and len(_lines) > 0:
				_line_speed = initial_line_speed
				_line_spawn_interval = initial_line_spawn_interval
				emit_signal("line_missed")
	
	
func _spawn_line():
	if not visible:
		return

	var line = TaskLineScene.instantiate() as Control
	(line as TextureRect).texture = Player1LineTexture if _is_player_1 else Player2LineTexture
	line.set_anchors_preset(Control.PRESET_CENTER_RIGHT, false)
	var index = _rand.randi_range(0, _slides.size() - 1)
	_slides[index].add_child(line)
	line.owner = _slides[index]
	_lines.append(line)		
	get_tree().create_timer(_line_spawn_interval).timeout.connect(_spawn_line)
	
func set_is_player_1(in_is_player_1):
	_is_player_1 = in_is_player_1
	
	$WhiteLines.texture = Player1WholeTexture if _is_player_1 else Player2WholeTexture
	
	# Add the button actions
	_slide_actions.append(str("player_" + ("1" if _is_player_1 else "2") + "_punch"))
	_slide_actions.append(str("player_" + ("1" if _is_player_1 else "2") + "_kick"))
	_slide_actions.append(str("player_" + ("1" if _is_player_1 else "2") + "_solve"))
	
	var show_buttons = _player_1_buttons if _is_player_1 else _player_2_buttons 
	var hide_buttons = _player_2_buttons if _is_player_1 else _player_1_buttons 
	var show_dashes = _player_1_dashes if _is_player_1 else _player_2_dashes
	var hide_dashes = _player_2_dashes if _is_player_1 else _player_1_dashes
	
	show_buttons[0].find_child("Label").text = "T" if _is_player_1 else "M"
	show_buttons[1].find_child("Label").text = "Y" if _is_player_1 else ","
	show_buttons[2].find_child("Label").text = "U" if _is_player_1 else "."
	
	for dash in show_dashes:
		dash.visible = true
	for dash in hide_dashes:
		dash.visible = false
	
	for i in len(hide_buttons):
		hide_buttons[i].visible = false

func _on_player_started_solving(is_player_1, position_x):
	if _is_player_1 != is_player_1:
		return

	visible = true
	_line_spawn_interval = initial_line_spawn_interval
	_line_speed = initial_line_speed
	get_tree().create_timer(_line_spawn_interval).timeout.connect(_spawn_line)
	
func _on_player_stopped_solving(is_player_1):
	for node in _lines:
		node.queue_free()
		_lines.erase(node)
	visible = false
