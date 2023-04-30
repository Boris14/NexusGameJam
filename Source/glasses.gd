extends RigidBody2D

signal started_glasses_pickup(pickup_time)

@export var max_pickup_time = 4

const PickupBar = preload("res://Source/UI/pickup_bar.gd")

var player_owner
var _pickup_bar
var _is_touching_owner = false
var _pick_action

# Called when the node enters the scene tree for the first time.
func _ready():
	_is_touching_owner = false
	_pickup_bar = $PickupBar as PickupBar
	_pickup_bar.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	for body in $InteractArea.get_overlapping_bodies():
		if body == player_owner:
			$PickupBar.visible = true
			_is_touching_owner = true
			return
	$PickupBar.visible = false
	_is_touching_owner = false

	
# If he touches them, pick them up (destroy self)
func _on_player_tried_glasses_pickup(player):
	if _is_touching_owner and _pickup_bar.is_indicator_moving:
		var pick_value = _pickup_bar.stop_indicator() # returns [0; 1]
		var time = remap(pick_value, 0, 1, 0, max_pickup_time)
		emit_signal("started_glasses_pickup", time)
		await get_tree().create_timer(time / 2).timeout
		queue_free()
