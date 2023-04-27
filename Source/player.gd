extends CharacterBody2D

signal health_changed(is_player_1, new_health, max_health)
signal dropped_glasses(player)
# When the player is without glasses and presses punch_action 
signal tried_glasses_pickup(player)

@export var speed = 300.0
@export var max_jump_velocity = -800.0
@export var max_jump_hold_time = 0.2
@export var max_health = 100.0
@export var punch_damage = 10.0
@export var kick_damage = 20.0

# How fast the player reaches it's max_jump_velocity (not changing is recommended)
const JUMP_FORCE = 20 

# Player States
var _is_jumping = false
var _is_without_glasses = false
var _is_picking_up_glasses = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_time = 0
var _health = max_health

# Controls
var _move_left_action
var _move_right_action
var _jump_action
var _punch_action
var _kick_action
var _block_action

func _ready():
	_is_jumping = false
	_is_without_glasses = false
	_jump_time = 0
	_health = max_health
	_move_left_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_left")
	_move_right_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_right")
	_jump_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_jump")
	_punch_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_punch")
	_kick_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_kick")
	_block_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_block")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	if _is_picking_up_glasses:
		return

	# Handle Jump.
	if Input.is_action_just_pressed(_jump_action) and is_on_floor():
		_is_jumping = true
	elif Input.is_action_just_released(_jump_action):
		_is_jumping = false
		_jump_time = 0
	if (
		_is_jumping and Input.is_action_pressed(_jump_action) 
		and _jump_time < max_jump_hold_time
	):
		velocity.y = lerp(velocity.y, max_jump_velocity, delta * JUMP_FORCE)
		_jump_time += delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(_move_left_action, _move_right_action)
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	
	# Punch yourself to test the healthbar
	if Input.is_action_just_pressed(_punch_action):
		if _is_without_glasses:
			emit_signal("tried_glasses_pickup", self)
		else:
			take_damage(punch_damage)


func take_damage(damage):
	_health -= damage
	_health = clamp(_health, 0, max_health)
	emit_signal("health_changed", get_meta("is_player_1"), _health, max_health)
	if _health <= 0:
		# Drops glasses
		_is_without_glasses = true
		emit_signal("dropped_glasses", self)
		
func _on_started_glasses_pickup(pickup_time):
	_is_picking_up_glasses = true
	await get_tree().create_timer(pickup_time).timeout
	take_damage(-max_health)
	_is_picking_up_glasses = false
	_is_without_glasses = false
	
		
	
