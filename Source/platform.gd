extends StaticBody2D


var _time_to_disable = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_time_to_disable -= delta
	#if _time_to_disable <= 0:
		#$CollisionShape2D.disabled = true
