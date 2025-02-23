class_name Map extends Node3D

@export var map_name: String

func _ready() -> void:
	$LootBoxSpawnPositions.set_visible(false)
	$PlayerSpawnPositions.set_visible(false)

func get_loot_box_spawn_positions() -> Array[Node]:
	return $LootBoxSpawnPositions.get_children()
	
func get_player_spawn_positions() -> Array[Node]:
	return $PlayerSpawnPositions.get_children()
