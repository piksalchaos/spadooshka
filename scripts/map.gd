class_name Map extends Node3D

@export var map_name: String
@onready var loot_box_spawn_positions: Array[Node] = $LootBoxSpawnPositions.get_children()
@onready var player_spawn_positions: Array[Node] = $PlayerSpawnPositions.get_children()

func _ready() -> void:
	$LootBoxSpawnPositions.set_visible(false)
	$PlayerSpawnPositions.set_visible(false)
