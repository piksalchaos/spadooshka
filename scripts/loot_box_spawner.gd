class_name LootBoxSpawner extends Node3D

const ITEM_FILE_NAMES: PackedStringArray = [
	"res://scenes/item-scenes/speed_boost.tscn",
	"res://scenes/item-scenes/jump_boost.tscn",
	"res://scenes/item-scenes/grappling_hook.tscn",
	"res://scenes/item-scenes/grenade_item.tscn"
	]

@export var num_boxes: int = 3
@export var multiplayer_container: Node

var loot_box_scene: PackedScene = load("res://scenes/loot_box.tscn")

func spawn(spawn_positions: Array[Node]) -> void:
	spawn_positions = spawn_positions.duplicate()
	
	for i in range(num_boxes):
		var loot_box = loot_box_scene.instantiate()
		
		var random_index = randi_range(0, spawn_positions.size() - 1)
		loot_box.global_transform = spawn_positions[random_index].global_transform
		spawn_positions.remove_at(random_index)
		
		multiplayer_container.add_child(loot_box, true)
