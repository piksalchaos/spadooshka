class_name Client extends Node

const PLAYER_SCENE = preload("res://scenes/player.tscn")

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func create_player() -> Player:
	var player = PLAYER_SCENE.instantiate()
	player.name = name
	return player
