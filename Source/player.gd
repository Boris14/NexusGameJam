extends CharacterBody2D

signal health_changed(is_player_1, new_health, max_health)
signal dropped_glasses(player)
# When the player is without glasses and presses punch_action 
signal tried_glasses_pickup(player)
signal picked_up_glasses(player)
signal tried_start_solving(player)
signal changed_solve_score(is_player_1, solve_score, max_solve_score)
signal punched()
signal kicked()
signal started_walking()
signal stopped_walking()
signal won(is_player_1)
signal jumped()

@export var speed = 300.0
@export var no_glasses_speed_debuff = 0.3
@export var max_jump_velocity = -800.0
@export var max_jump_hold_time = 0.2
@export var max_health = 100.0
@export var max_solve_score = 30
@export var punch_damage = 10.0
@export var kick_damage = 15.0
@export var punch_block_duration = 0.2
@export var punch_duration = 0.3
@export var kick_block_duration = 0.4
@export var kick_duration = 0.3
@export var blocking_attacks_duration = 1
@export var block_coef = 0.33

# How fast the player reaches it's max_jump_velocity (not changing is recommended)
const JUMP_FORCE = 30 

# Player States
var _is_jumping = false
var _is_in_jumping_animation = false
var _is_without_glasses = false
var _is_picking_up_glasses = false
var _is_facing_left = false
var _is_movement_blocked = false
var _is_solving = false
var _is_blocking_attacks
var _is_knocked_back = false
var _has_finished = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _jump_time = 0
var _health = max_health
var _speed = speed
var solve_score = 0 

# Controls
var _move_left_action
var _move_right_action
var _jump_action
var _punch_action
var _kick_action
var _block_action
var _solve_action
var _state_machine
var _is_walking

func _ready():
	if not get_meta("is_player_1"):
		$Sprite2D.texture = load("res://Assets/PlayerSprites/second_character.svg")
	
	_state_machine = $AnimationTree.get("parameters/playback")
	_is_blocking_attacks = false
	_is_jumping = false
	_is_without_glasses = false
	_is_facing_left = not get_meta("is_player_1")
	_jump_time = 0
	take_damage(-max_health)
	_add_solve_score(0)
	_move_left_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_left")
	_move_right_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_right")
	_jump_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_jump")
	_punch_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_punch")
	_kick_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_kick")
	_block_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_block")
	_solve_action = str("player_" + ("1" if get_meta("is_player_1") else "2") + "_solve")
	
	if not get_meta("is_player_1"): # initial flip
		get_node("Sprite2D").set_flip_h(true)


func _physics_process(delta):
	if _has_finished:
		return
		
	if velocity.y < 0:
		_is_in_jumping_animation = true
		_state_machine.travel("jumpLoop")
	elif velocity.y > 0:
		_is_in_jumping_animation = true
		_state_machine.travel("fallLoop")
	else:
		_is_in_jumping_animation = false
	
	if _is_picking_up_glasses or _is_solving:
		return

	# Add the gravity.
	if not is_on_floor(): ## THIS IS ALWAYS TRUE?
		velocity.y += gravity * delta

	# Handle Combat actions
	if (not _is_movement_blocked and 
		not _is_without_glasses and 
		is_on_floor()):
		if Input.is_action_just_pressed(_punch_action):
			_is_movement_blocked = true
			_state_machine.travel("punching")
			get_tree().create_timer(punch_duration).timeout.connect(_punch)
		elif Input.is_action_just_pressed(_kick_action):
			_is_movement_blocked = true
			_state_machine.travel("kicking")
			get_tree().create_timer(kick_duration).timeout.connect(_kick)
		if Input.is_action_pressed(_block_action):
			_state_machine.travel("block")
			_is_movement_blocked = true
			_is_blocking_attacks = true
	if Input.is_action_just_released(_block_action):
		_is_movement_blocked = false
		_is_blocking_attacks = false
			
	if (Input.is_action_just_pressed(_solve_action) and 
		_is_without_glasses and is_on_floor()):
		emit_signal("tried_glasses_pickup", self)
		
	if (Input.is_action_just_pressed(_solve_action) and 
		not _is_without_glasses and is_on_floor() and 
		not _is_solving):
		emit_signal("tried_start_solving", self)

	if _is_movement_blocked:
		if _is_knocked_back and not _is_blocking_attacks:
			move_and_slide()
		return

	if _is_without_glasses:
		_speed = speed * no_glasses_speed_debuff
		_jump_time = max_jump_hold_time # Hack to prevent jumping

	# Handle Jump.
	if Input.is_action_just_pressed(_jump_action) and is_on_floor():
		_is_jumping = true
		_set_is_walking(false)
		emit_signal("jumped")
	elif Input.is_action_just_released(_jump_action):
		_is_jumping = false
		_jump_time = 0
	if (_is_jumping and Input.is_action_pressed(_jump_action) 
		and _jump_time < max_jump_hold_time):
		velocity.y = lerp(velocity.y, max_jump_velocity, delta * JUMP_FORCE)
		_jump_time += delta

	if _is_knocked_back and not _is_blocking_attacks:
		move_and_slide()
		return
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis(_move_left_action, _move_right_action)
	if direction:
		if is_on_floor() and not _is_jumping:
			_set_is_walking(true)
		if not _is_jumping and not _is_in_jumping_animation and not _is_solving:
			_state_machine.travel("walking" if not _is_without_glasses else "crawling")
		_change_facing_direction(direction)
		velocity.x = direction * _speed
	else:
		_set_is_walking(false)
		if not _is_jumping and not _is_in_jumping_animation and not _is_solving:
			_state_machine.travel("idle" if not _is_without_glasses else "crawling_idle")
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()
	

func take_damage(damage):
		_health -= damage if not _is_blocking_attacks else block_coef * damage
		_health = clamp(_health, 0, max_health)
		emit_signal("health_changed", get_meta("is_player_1"), _health, max_health)
		if _health <= 0 and not _is_without_glasses:
			# Drops glasses
			_is_without_glasses = true
			emit_signal("dropped_glasses", self)


func apply_knockback(is_to_the_left, damage):
	if _is_blocking_attacks:
		return false
		
	var knockback = 300 + damage * 30
	if is_to_the_left:
		velocity.x -= knockback
	else:
		velocity.x += knockback
	_is_knocked_back = true
	get_tree().create_timer(0.1).timeout.connect(_disable_knockback)
	return true		
	
	
func win():
	_is_without_glasses = false
	_is_solving = false
	_is_movement_blocked = true
	_has_finished = true
	_set_is_walking(false)
	_state_machine.travel("idle")
	emit_signal("won", get_meta("is_player_1"))
	
func lose():
	_is_without_glasses = false
	_is_solving = false
	_is_movement_blocked = true
	_has_finished = true
	_set_is_walking(false)
	_state_machine.travel("idle")
	
func _disable_knockback():
	_is_knocked_back = false	
	
	
func _set_is_walking(is_walking):
	if _is_walking == is_walking:
		return
	
	emit_signal("started_walking" if is_walking else "stopped_walking")
	_is_walking = is_walking
	
	
	
func _on_started_glasses_pickup(pickup_time):
	_is_picking_up_glasses = true
	await get_tree().create_timer(pickup_time).timeout
	take_damage(-max_health)
	_is_picking_up_glasses = false
	_is_without_glasses = false
	_speed = speed
	_jump_time = 0
	emit_signal("picked_up_glasses", self)
	

func _activate_hit_area(is_facing_left, damage, is_kick):
	var HitArea
	if is_kick:
		HitArea = $LeftKickArea if is_facing_left else $RightKickArea
	else:
		HitArea = $LeftPunchArea if is_facing_left else $RightPunchArea

	var block_duration = kick_block_duration if is_kick else punch_block_duration
	for body in HitArea.get_overlapping_bodies():
		if body.has_method("take_damage") and body != self:
			body.take_damage(damage)
			var succeeded = body.apply_knockback(is_facing_left, damage)
			if succeeded:
				return block_duration
			else:
				$AnimationTree.active = false
				get_tree().create_timer(block_duration).timeout.connect(_resume_animation)
				return block_duration * 2
	return block_duration

func _resume_animation():
	$AnimationTree.active = true


func _change_facing_direction(direction):
	if direction == 1:
		get_node("Sprite2D").set_flip_h(false)
		_is_facing_left = false
	else:
		_is_facing_left = true
		get_node("Sprite2D").set_flip_h(true)


func _reset_movement():
	_is_movement_blocked = false
	
	
func _reset_block():
	_is_blocking_attacks = false
	_reset_movement()
	
	
func _punch():
	var timer_dur = _activate_hit_area(_is_facing_left, punch_damage, false)
	get_tree().create_timer(timer_dur).timeout.connect(_reset_movement)
	emit_signal("punched")
	

func _kick():
	var timer_dur = _activate_hit_area(_is_facing_left, kick_damage, true)
	get_tree().create_timer(timer_dur).timeout.connect(_reset_movement)
	emit_signal("kicked")
		
func _on_started_solving(is_player_1, pos):
	if get_meta("is_player_1") != is_player_1:
		return
		
	_is_solving = true
	velocity - Vector2(0, 0)
	position = pos
	_add_solve_score(0)
	

func _on_stopped_solving(is_player_1):
	if get_meta("is_player_1") != is_player_1:
		return 
		
	_is_solving = false
	
	
func _on_line_hit():
	_add_solve_score(1)
	
	
func _add_solve_score(score):
	solve_score += score
	emit_signal("changed_solve_score", get_meta("is_player_1"), solve_score, max_solve_score)
	if float(solve_score) / max_solve_score < 0.6 and _state_machine.get_current_node() != "writing_up":
		_state_machine.travel("writing_up")
	elif _state_machine.get_current_node() != "writing_down":
		_state_machine.travel("writing_down")
		
	if solve_score >= max_solve_score:
		win()
