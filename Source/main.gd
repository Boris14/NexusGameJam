extends Node

const Player = preload("res://Source/player.gd")
const HUD = preload("res://Source/UI/hud.gd")
const Glasses = preload("res://Source/glasses.gd")
const TaskSolver = preload("res://Source/UI/task_solver.gd")
const Blackboard = preload("res://Source/blackboard.gd")
const PauseMenu = preload("res://Source/UI/pause_menu.gd")

const PlayerScene = preload("res://Scenes/player.tscn")
const GlassesScene = preload("res://Scenes/Glasses.tscn")

var player_1_task_solver : TaskSolver
var player_2_task_solver : TaskSolver
var blackboard : Blackboard
var pause_menu : PauseMenu
var hud : HUD

const hit_sounds = [
	"res://Audio/ES_Cartoon Voice 12.mp3",
	"res://Audio/ES_Cartoon Voice 13.mp3",
	"res://Audio/ES_Cartoon Voice 14.mp3",
	"res://Audio/ES_Cartoon Voice 15.mp3",
	"res://Audio/ES_Cartoon Voice 16.mp3",
	"res://Audio/ES_Cartoon Voice 17.mp3",
	"res://Audio/ES_Cartoon Voice 18.mp3"]
	
const punch_sounds = [
	"res://Audio/ES_Punch Face Cartoon 1.mp3",
	"res://Audio/ES_Punch Face Cartoon 2.mp3",
	"res://Audio/ES_Punch Face Cartoon 3.mp3",
	"res://Audio/ES_Punch Face Cartoon 4.mp3",
	"res://Audio/ES_Punch Face Cartoon 5.mp3",
]

const kick_sounds = [
	"res://Audio/ES_Punch Face Heavy 1.mp3",
	"res://Audio/ES_Punch Face Hard 6.mp3",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	var music = load("res://Audio/ES_Tiger Tracks.mp3")
	$MainMusic.set_stream(music)
	$MainMusic.play()
	player_1_task_solver = $Player1TaskSolver as TaskSolver
	player_2_task_solver = $Player2TaskSolver as TaskSolver
	player_1_task_solver.set_is_player_1(true)
	player_2_task_solver.set_is_player_1(false)
	hud = $HUD as HUD
	hud.connect("round_ended", _on_round_ended)
	pause_menu = $PauseMenu as PauseMenu
	pause_menu.visible = false
	blackboard = $Blackboard as Blackboard
	blackboard.connect("started_solving", player_1_task_solver._on_player_started_solving)
	blackboard.connect("started_solving", player_2_task_solver._on_player_started_solving)
	blackboard.connect("stopped_solving", player_1_task_solver._on_player_stopped_solving)
	blackboard.connect("stopped_solving", player_2_task_solver._on_player_stopped_solving)
	blackboard.connect("started_solving", _on_started_solving)
	blackboard.connect("stopped_solving", _on_stopped_solving)
	_spawn_player(true)
	_spawn_player(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_cancel") and not pause_menu.visible:
		Input.action_release("ui_cancel")
		pause_menu.pause()
	
	
func _spawn_player(is_player_1):
	var player = PlayerScene.instantiate() as Player
	player.set_meta("is_player_1", is_player_1)
	player.position = ($Player1StartPosition if is_player_1 else $Player2StartPosition).position
	player.connect("health_changed", _on_player_health_changed)
	player.connect("health_changed", hud._on_player_health_changed)
	player.connect("dropped_glasses", _on_player_dropped_glasses)
	player.connect("dropped_glasses", blackboard._on_player_dropped_glasses)
	player.connect("tried_start_solving", blackboard._on_player_tried_start_solving)
	player.connect("picked_up_glasses", blackboard._on_player_picked_up_glasses)
	player.connect("changed_solve_score", blackboard._on_player_changed_solve_score)
	player.connect("kicked", _on_player_kicked)
	player.connect("punched", _on_player_punched)
	player.connect("changed_solve_score", hud._on_player_solve_score_changed)
	blackboard.connect("started_solving", player._on_started_solving)
	blackboard.connect("stopped_solving", player._on_stopped_solving)
	if is_player_1:
		player_1_task_solver.connect("line_hit", player._on_line_hit)
	else:
		player_2_task_solver.connect("line_hit", player._on_line_hit)
	add_child(player)
	
	
# Spawn the glasses and connect the needed signals
func _on_player_dropped_glasses(player):
	var sound_fx = load("res://Audio/ES_Metal Drop 32.mp3")
	$Glasses.set_stream(sound_fx)
	$Glasses.play()
	
	var glasses = GlassesScene.instantiate() as Glasses
	glasses.position = player.position
	glasses.player_owner = player
	glasses.connect("started_glasses_pickup", (player as Player)._on_started_glasses_pickup)
	player.connect("tried_glasses_pickup", glasses._on_player_tried_glasses_pickup)
	add_child(glasses)	

func _on_player_health_changed(is_player_1, new_health, max_health):
	if new_health < max_health:
		var index = randi_range(0, hit_sounds.size())
		var sound_fx = load(hit_sounds[index - 1])
		$HitAudio.set_stream(sound_fx)
		$HitAudio.play()
		
func _on_player_punched():
	var index = randi_range(0, punch_sounds.size())
	var sound_fx = load(punch_sounds[index - 1])
	$Punch.set_stream(sound_fx)
	$Punch.play()
	
func _on_player_kicked():
	var index = randi_range(0, kick_sounds.size())
	var sound_fx = load(kick_sounds[index - 1])
	$Kick.set_stream(sound_fx)
	$Kick.play()
	
func _on_started_solving(is_player_1, pos):
	$Solving.play()
	
func _on_stopped_solving(is_player_1):
	$Solving.stop()
	

func _on_round_ended():
	# End screen
	get_tree().quit()
