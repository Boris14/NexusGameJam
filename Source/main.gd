extends Node

const Player = preload("res://Source/player.gd")
const HUD = preload("res://Source/UI/hud.gd")
const Glasses = preload("res://Source/glasses.gd")
const TaskSolver = preload("res://Source/UI/task_solver.gd")
const Blackboard = preload("res://Source/blackboard.gd")
const Platform = preload("res://Source/platform.gd")

const PlayerScene = preload("res://Scenes/Player.tscn")
const GlassesScene = preload("res://Scenes/Glasses.tscn")

var player_1_task_solver : TaskSolver
var player_2_task_solver : TaskSolver
var blackboard : Blackboard
var platform : Platform

# Called when the node enters the scene tree for the first time.
func _ready():
	player_1_task_solver = $Player1TaskSolver as TaskSolver
	player_2_task_solver = $Player2TaskSolver as TaskSolver
	player_1_task_solver.set_is_player_1(true)
	player_2_task_solver.set_is_player_1(false)
	blackboard = $Blackboard as Blackboard
	blackboard.connect("started_solving", player_1_task_solver._on_player_started_solving)
	blackboard.connect("started_solving", player_2_task_solver._on_player_started_solving)
	blackboard.connect("stopped_solving", player_1_task_solver._on_player_stopped_solving)
	blackboard.connect("stopped_solving", player_2_task_solver._on_player_stopped_solving)
	platform = $Platform as Platform
	_spawn_player(true)
	_spawn_player(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func _spawn_player(is_player_1):
	var player = PlayerScene.instantiate() as Player
	player.set_meta("is_player_1", is_player_1)
	player.position = ($Player1StartPosition if is_player_1 else $Player2StartPosition).position
	player.connect("health_changed", ($HUD as HUD)._on_player_health_changed)
	player.connect("dropped_glasses", _on_player_dropped_glasses)
	player.connect("dropped_glasses", platform._on_player_dropped_glasses)
	player.connect("tried_start_solving", blackboard._on_player_tried_start_solving)
	player.connect("picked_up_glasses", platform._on_player_picked_up_glasses)
	player.connect("picked_up_glasses", blackboard._on_player_picked_up_glasses)
	blackboard.connect("started_solving", player._on_started_solving)
	blackboard.connect("stopped_solving", player._on_stopped_solving)
	if is_player_1:
		player_1_task_solver.connect("line_hit", player._on_line_hit)
	else:
		player_2_task_solver.connect("line_hit", player._on_line_hit)
	add_child(player)
	
	
# Spawn the glasses and connect the needed signals
func _on_player_dropped_glasses(player):
	var glasses = GlassesScene.instantiate() as Glasses
	glasses.position = player.position
	glasses.player_owner = player
	glasses.connect("started_glasses_pickup", (player as Player)._on_started_glasses_pickup)
	player.connect("tried_glasses_pickup", glasses._on_player_tried_glasses_pickup)
	add_child(glasses)	
