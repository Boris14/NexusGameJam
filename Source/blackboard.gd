extends Area2D

const Player = preload("res://Source/player.gd")

signal started_solving(is_player_1, position_x)
signal stopped_solving(is_player_1)

var _is_active = false
var _player_1_solve_x
var _player_2_solve_x

# Called when the node enters the scene tree for the first time.
func _ready():
	_player_1_solve_x = position.x - ($Sprite2D.get_rect().size.x / 4 * scale.x)
	_player_2_solve_x = position.x + ($Sprite2D.get_rect().size.x / 4 * scale.x)
	$Outline.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _is_active:
		return
	
	for node in get_overlapping_bodies():
		if (node.is_class("CharacterBody2D") and 
			node.has_method("is_on_floor") and 
			node.is_on_floor()):
			$Outline.visible = true
			return
			
	if $Outline.visible:
		$Outline.visible = false 
	
	
func _on_player_tried_start_solving(player):
	if _is_active:
		return
		
	for node in get_overlapping_bodies():
		if node == player:
			$Outline.visible = false
			var is_player_1 = player.get_meta("is_player_1")
			var solve_pos_x = _player_1_solve_x if is_player_1 else _player_2_solve_x
			emit_signal("started_solving", is_player_1, solve_pos_x)
			_is_active = true
	
	
func _on_player_picked_up_glasses(player):
	_is_active = false
	emit_signal("stopped_solving", not player.get_meta("is_player_1"))
