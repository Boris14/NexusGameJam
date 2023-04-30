extends Area2D

signal started_solving(is_player_1)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
	
func _on_player_tried_start_solving(player):
	for node in get_overlapping_bodies():
		if node == player:
			emit_signal("started_solving", player.get_meta("is_player_1"))
	
