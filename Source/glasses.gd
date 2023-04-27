extends RigidBody2D

signal glasses_picked_up()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print($InteractArea.get_overlapping_bodies().size())
	pass
	
# If he touches them, pick them up (destroy self)
func _on_player_try_pickup_glasses(player):
	for body in $InteractArea.get_overlapping_bodies():
		if body == player:
			emit_signal("glasses_picked_up")
			queue_free()
