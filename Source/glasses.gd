extends RigidBody2D

const Player1HighlightedTexture = preload("res://Assets/SVG/glasses/glasses with white border.svg")
const Player1NormalTexture = preload("res://Assets/SVG/glasses/glasses.svg")
const Player2HighlightedTexture = preload("res://Assets/second character/glasses with border 2.svg")
const Player2NormalTexture = preload("res://Assets/second character/glasses 2.svg")

signal started_glasses_pickup(pickup_time)

@export var max_pickup_time = 6
@export var impulse_force = 1000

const PickupBar = preload("res://Source/UI/pickup_bar.gd")

var player_owner
var _pickup_bar
var _is_touching_owner = false
var _idle_velocity_length = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	lock_rotation = true
	_is_touching_owner = false
	_pickup_bar = $PickupBar as PickupBar
	_pickup_bar.visible = false
	_pickup_bar.set_is_player_1(player_owner.get_meta("is_player_1"))
	await get_tree().create_timer(0.01).timeout
	var impulse_dir = Vector2(randf_range(-1, 1), -1)
	apply_impulse(impulse_dir * impulse_force)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	angular_damp = 0
	for body in $InteractArea.get_overlapping_bodies():
		if body == player_owner and linear_velocity.length() < _idle_velocity_length:
			if player_owner.get_meta("is_player_1"):
				$Sprite2D.texture = Player1HighlightedTexture
			else:
				$Sprite2D.texture = Player2HighlightedTexture
			$PickupBar.visible = true
			_is_touching_owner = true
			return
	if player_owner.get_meta("is_player_1"):
		$Sprite2D.texture = Player1NormalTexture
	else:
		$Sprite2D.texture = Player2NormalTexture
	$PickupBar.visible = false
	_is_touching_owner = false

	
# If he touches them, pick them up (destroy self)
func _on_player_tried_glasses_pickup(player):
	if _is_touching_owner and _pickup_bar.is_indicator_moving:
		var pick_value = _pickup_bar.stop_indicator() # returns [0; 1]
		var time = remap(pick_value, 0, 1, 0.4, max_pickup_time)
		emit_signal("started_glasses_pickup", time)
		await get_tree().create_timer(time / 2).timeout
		queue_free()
