extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D.disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Use $CollisionShape2D.disabled = true when you want to disable the collision
	pass

	
func _on_player_dropped_glasses(player):
	#$CollisionShape2D.disabled = false

	
func _on_player_picked_up_glasses(player):
	$CollisionShape2D.disabled = true
