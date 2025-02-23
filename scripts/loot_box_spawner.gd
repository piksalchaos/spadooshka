class_name LootBoxSpawner extends Node3D

@export var num_boxes: int = 3
@export var multiplayer_container: Node

var loot_box_scene: PackedScene = preload("res://scenes/loot_box.tscn")

@rpc("any_peer", "call_local")
func spawn(spawn_positions: Array[Node]) -> void:
	#print(multiplayer_container)
	
	var indices: Array = range(spawn_positions.size())
	indices.shuffle()
	
	for i in range(num_boxes):
		var loot_box = loot_box_scene.instantiate()
		loot_box.global_transform = spawn_positions[indices.pop_back()].global_transform
		
		multiplayer_container.add_child(loot_box, true)
