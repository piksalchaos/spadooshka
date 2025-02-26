class_name Map extends Node3D

@export var map_name: String
@onready var loot_box_spawner: MultiplayerSpawner = $LootBoxSpawner

var players: Array[Player] = []

func _ready() -> void:
	$LootBoxSpawnPositions.set_visible(false)
	$PlayerSpawnPositions.set_visible(false)

func get_loot_box_spawn_transforms() -> Array[Transform3D]:
	var spawn_transforms: Array[Transform3D] = []
	
	for loot_box in $LootBoxSpawnPositions.get_children():
		spawn_transforms.append(loot_box.global_transform)
		
	return spawn_transforms

func get_player_spawn_positions() -> Array[Transform3D]:
	var spawn_transforms: Array[Transform3D] = []
	
	for loot_box in $PlayerSpawnPositions.get_children():
		spawn_transforms.append(loot_box.global_transform)
		
	return spawn_transforms

func spawn_players():
	var spawn_transforms = get_player_spawn_positions()
	
	var indices: Array = range(spawn_transforms.size())
	indices.shuffle()
	
	for player in players:
		var spawn_transform: Transform3D = spawn_transforms[indices.pop_back()]
		player.spawn.rpc(spawn_transform)

func spawn_loot_boxes():
	loot_box_spawner.spawn_loot_boxes(get_loot_box_spawn_transforms())

func despawn_loot_boxes():
	loot_box_spawner.despawn_loot_boxes()
