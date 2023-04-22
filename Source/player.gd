extends CharacterBody2D

@export var speed = 300.0
@export var jump_velocity = -600.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _is_jumping = false;

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if _is_jumping:
		if Input.is_action_pressed("player_1_jump"):
			velocity.y = lerp(velocity.y, jump_velocity, delta * 100)
		else:
			_is_jumping = false
	elif Input.is_action_just_pressed("player_1_jump") and is_on_floor():
		_is_jumping = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_1_left", "player_1_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
