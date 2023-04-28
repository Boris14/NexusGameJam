extends CharacterBody2D

signal health_changed(is_player_1, new_health, max_health)

@export var speed = 300.0
@export var max_jump_velocity = -800.0
@export var max_jump_hold_time = 0.2
@export var max_health = 100.0
@export var punch_damage = 10.0
@export var kick_damage = 20.0
@export var punch_block_duration = 0.5
@export var punch_duration = 0.5
@export var kick_block_duration = 1
@export var kick_duration = 1

# How fast the player reaches it's max_jump_velocity (not changing is recommended)
const JUMP_FORCE = 20 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_time = 0
var _is_jumping = false
var _health = max_health
var _is_facing_left = false
var _is_punch_blocked = false
var _is_kick_blocked = false

# Controls
var _move_left_action
var _move_right_action
var _jump_action
var _punch_action
var _kick_action
var _block_action

func _ready():
	_is_jumping = false
	_jump_time = 0
	_health = max_health
	_is_facing_left = not get_meta("is_player_1")
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
		_change_facing_direction(direction)
		velocity.x = direction * speed
		
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	
	if Input.is_action_just_pressed(_punch_action):

		if _is_punch_blocked:
			return
		_is_punch_blocked = true
		get_tree().create_timer(punch_duration).timeout.connect(punch)
			
	if Input.is_action_just_pressed(_kick_action):

		if _is_kick_blocked:
			return
		_is_kick_blocked = true
		get_tree().create_timer(kick_duration).timeout.connect(kick)

func take_damage(damage):
	_health -= damage
	_health = clamp(_health, 0, max_health)
	emit_signal("health_changed", get_meta("is_player_1"), _health, max_health)
	if _health <= 0:
		queue_free()
		
func _activate_hit_area(is_facing_left, damage):
	if (is_facing_left):
		for body in $LeftHitArea.get_overlapping_bodies():
			if body.has_method("take_damage") and body != self:
				body.take_damage(damage)
	else:
		for body in $RightHitArea.get_overlapping_bodies():
			if body.has_method("take_damage") and body != self:
				body.take_damage(damage)

func _change_facing_direction(direction):
	if direction == 1:
		_is_facing_left = false
	else:
		_is_facing_left = true

func _reset_punch_block():
	_is_punch_blocked = false
	
func _reset_kick_block():
	_is_kick_blocked = false

func punch():
	_activate_hit_area(_is_facing_left, punch_damage)
	get_tree().create_timer(punch_block_duration).timeout.connect(_reset_punch_block)
	
func kick():
	_activate_hit_area(_is_facing_left, kick_damage)
	get_tree().create_timer(kick_block_duration).timeout.connect(_reset_kick_block)

