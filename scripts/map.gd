class_name Map extends Node3D

@export var map_name: String
@onready var loot_box_spawner: MultiplayerSpawner = $LootBoxSpawner

var players: Array[Player] = []

signal connect_player_signals(player: Player)

func _ready() -> void:
	$LootBoxSpawnPositions.set_visible(false)
	$PlayerSpawnPositions.set_visible(false)

func get_loot_box_spawn_positions() -> Array[Node]:
	return $LootBoxSpawnPositions.get_children()
	
func get_player_spawn_positions() -> Array[Node]:
	return $PlayerSpawnPositions.get_children()

func spawn_players():
	var spawn_positions = get_player_spawn_positions()
	
	var indices: Array = range(spawn_positions.size())
	indices.shuffle()
	
	for player in players:
		var spawn_position: Vector3 = spawn_positions[indices.pop_back()].position
		player.spawn.rpc(spawn_position)

func spawn_loot_boxes():
	loot_box_spawner.spawn_loot_boxes(get_loot_box_spawn_positions())

func despawn_loot_boxes():
	loot_box_spawner.despawn_loot_boxes()
