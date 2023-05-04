extends Area2D

const Player = preload("res://Source/player.gd")

const HighlightedTexture = preload("res://Assets/SVG/blackboard glowing.svg")
const NormalTexture = preload("res://Assets/SVG/blackboard.svg")

signal started_solving(is_player_1, pos)
signal stopped_solving(is_player_1)

@export var solve_y_offset = -60
@export var start_solve_y_offset = 20

var _is_active = false
var _player_1_solve_x
var _player_2_solve_x
var _player_1_is_without_glasses = false
var _player_2_is_without_glasses = false
var _player_1_panel : Control
var _player_2_panel : Control
var _max_panel_height : float

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_1_panel = $Base/Player1Panel as Control
	_player_2_panel = $Base/Player2Panel as Control
	_max_panel_height = _player_1_panel.size.y
	_player_1_panel.size.y = start_solve_y_offset - start_solve_y_offset
	_player_2_panel.size.y = start_solve_y_offset - start_solve_y_offset
	_player_1_solve_x = position.x - ($Base.get_rect().size.x * $Base.scale.x / 4 * scale.x)
	_player_2_solve_x = position.x + ($Base.get_rect().size.x * $Base.scale.x / 4 * scale.x)
	$Base.texture = HighlightedTexture


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _is_active:
		return
	
	for node in get_overlapping_bodies():
		if (node.is_class("CharacterBody2D") and 
			node.has_method("is_on_floor") and 
			node.is_on_floor() and 
			(_player_1_is_without_glasses or _player_2_is_without_glasses)):
				if node.get_meta("is_player_1"):
					if not _player_1_is_without_glasses:
						$Base.texture = HighlightedTexture
						return
				else:
					if not _player_2_is_without_glasses:
						$Base.texture = HighlightedTexture
						return
			
	if $Base.texture == HighlightedTexture:
		$Base.texture = NormalTexture
	
	
func _on_player_tried_start_solving(player):
	if _is_active:
		return
		
	var is_player_1 = player.get_meta("is_player_1")
	var player_can_solve
	if is_player_1:
		player_can_solve = _player_2_is_without_glasses and not _player_1_is_without_glasses
	else:
		player_can_solve = _player_1_is_without_glasses and not _player_2_is_without_glasses
	
	if not player_can_solve:
		return
	
	for node in get_overlapping_bodies():
		if node == player:
			$Base.texture = NormalTexture
			var solve_pos_x = _player_1_solve_x if is_player_1 else _player_2_solve_x
			var solve_pos_y = player.position.y + solve_y_offset
			emit_signal("started_solving", is_player_1, Vector2(solve_pos_x, solve_pos_y))
			_is_active = true
	
	
func _on_player_picked_up_glasses(player):
	_is_active = false
	var is_player_1 = player.get_meta("is_player_1")
	if is_player_1:
		_player_1_is_without_glasses = false
	else:
		_player_2_is_without_glasses = false
	emit_signal("stopped_solving", not is_player_1)
	

func _on_player_dropped_glasses(player):
	if player.get_meta("is_player_1"):
		_player_1_is_without_glasses = true
	else:
		_player_2_is_without_glasses = true
		

func _on_player_changed_solve_score(is_player_1, solve_score, max_solve_score):
	var height = _max_panel_height * solve_score / max_solve_score + start_solve_y_offset
	if is_player_1:
		_player_1_panel.size.y = height
	else:
		_player_2_panel.size.y = height
		
