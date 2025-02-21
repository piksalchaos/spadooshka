class_name LootBoxSpawner extends Node3D

@export var num_boxes: int = 3
@export var multiplayer_container: Node

var loot_box_scene: PackedScene = preload("res://scenes/loot_box.tscn")

func spawn(_spawn_positions: Array[Node]) -> void:
	var spawn_positions = _spawn_positions.duplicate()
	
	print(spawn_positions)
	
	for i in range(num_boxes):
		var loot_box = loot_box_scene.instantiate()
		
		var random_index = randi_range(0, spawn_positions.size() - 1)
		loot_box.global_transform = spawn_positions[random_index].global_transform
		spawn_positions.remove_at(random_index)
		
		multiplayer_container.add_child(loot_box, true)
