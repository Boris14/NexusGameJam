extends Node

const Player = preload("res://Source/player.gd")
const HUD = preload("res://Source/hud.gd")
const PlayerScene = preload("res://Scenes/Player.tscn")

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
	add_child(player)
