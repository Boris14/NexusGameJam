extends CharacterBody2D

@export var speed = 300.0
@export var max_jump_velocity = -800.0
@export var max_jump_hold_time = 0.2
@export var max_health = 100.0
@export var punch_damage = 10.0
@export var kick_damage = 20.0

# How fast the player reaches it's max_jump_velocity (not changing is recommended)
const JUMP_FORCE = 20 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_time = 0
var _is_jumping = false
var heatlh = max_health

func _enter_tree():
	_is_jumping = false
	_jump_time = 0
	heatlh = max_health

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("player_1_jump") and is_on_floor():
		_is_jumping = true
	elif Input.is_action_just_released("player_1_jump"):
		_is_jumping = false
		_jump_time = 0
	if (
		_is_jumping and Input.is_action_pressed("player_1_jump") 
		and _jump_time < max_jump_hold_time
	):
		velocity.y = lerp(velocity.y, max_jump_velocity, delta * JUMP_FORCE)
		_jump_time += delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_1_left", "player_1_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
