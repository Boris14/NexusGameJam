extends Area2D

const Player = preload("res://Source/player.gd")

signal started_solving(is_player_1)

var _is_active = false

# Called when the node enters the scene tree for the first time.
func _ready():
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
			emit_signal("started_solving", player.get_meta("is_player_1"))
			_is_active = true
	
