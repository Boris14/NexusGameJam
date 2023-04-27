extends Node

const Player = preload("res://Source/player.gd")
const HUD = preload("res://Source/hud.gd")
const Glasses = preload("res://Source/glasses.gd")

const PlayerScene = preload("res://Scenes/Player.tscn")
const GlassesScene = preload("res://Scenes/Glasses.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
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
	add_child(player)
	
# Spawn the glasses and connect the needed signals
func _on_player_dropped_glasses(player):
	var glasses = GlassesScene.instantiate() as Glasses
	glasses.position = player.position
	glasses.player_owner = player
	glasses.connect("started_glasses_pickup", (player as Player)._on_started_glasses_pickup)
	player.connect("tried_glasses_pickup", glasses._on_player_tried_glasses_pickup)
	add_child(glasses)	
