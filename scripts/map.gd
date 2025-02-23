class_name Map extends Node3D

@export var map_name: String

@onready var loot_box_spawner: MultiplayerSpawner = $LootBoxSpawner
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner

signal connect_player_signals(player: Player)

func _ready() -> void:
	$LootBoxSpawnPositions.set_visible(false)
	$PlayerSpawnPositions.set_visible(false)

func get_loot_box_spawn_positions() -> Array[Node]:
	return $LootBoxSpawnPositions.get_children()
	
func get_player_spawn_positions() -> Array[Node]:
	return $PlayerSpawnPositions.get_children()

func add_players():
	player_spawner.add_players()

func _on_player_spawner_child_entered_tree(node: Node) -> void:
	print("Player %d added." % node.get_multiplayer_authority())
	#if not node.is_multiplayer_authority(): return
	connect_player_signals.emit(node)

func spawn_everything():
	spawn_loot_boxes()
	spawn_players()

func spawn_players():
	player_spawner.spawn_players(get_player_spawn_positions())
	
func spawn_loot_boxes():
	loot_box_spawner.spawn_loot_boxes(get_loot_box_spawn_positions())
	
func despawn_loot_boxes():
	loot_box_spawner.despawn_loot_boxes()
