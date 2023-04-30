extends Panel

const TaskLineScene = preload("res://Scenes/UI/TaskLine.tscn")

@export var initial_line_spawn_interval = 3
@export var initial_line_speed = 50
@export var line_spawn_increase_rate = 0.003
@export var line_speed_increase_rate = 0.05
@export var hitbox_error = 0.1

var _rand = RandomNumberGenerator.new()
var _slides = []
var _lines = []
var _line_spawn_interval
var _line_speed
var _hitbox_x

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	_slides = [$VBoxContainer/Slide1, $VBoxContainer/Slide2, $VBoxContainer/Slide3]
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not visible:
		return 
	
	for node in _lines:
		var line = node as Control
		line.position.x -= delta * _line_speed
		if line.position.x <= 0:
			_lines.erase(line)
			line.queue_free()
	_line_spawn_interval -= delta * line_spawn_increase_rate
	_line_speed += delta * line_speed_increase_rate
	
	
func _spawn_line():
	if not visible:
		return
	
	var line = TaskLineScene.instantiate()
	line.set_anchors_preset(Control.PRESET_CENTER_RIGHT, false)
	_slides[_rand.randi_range(0, _slides.size() - 1)].add_child(line)
	_lines.append(line)		
	get_tree().create_timer(_line_spawn_interval).timeout.connect(_spawn_line)
	
func start_solving():
	visible = true
	_line_spawn_interval = initial_line_spawn_interval
	_line_speed = initial_line_speed
	_hitbox_x = _slides[0].position.x
	get_tree().create_timer(_line_spawn_interval).timeout.connect(_spawn_line)
	
func stop_solving():
	for node in _lines:
		node.queue_free()
		_lines.erase(node)
	visible = false
