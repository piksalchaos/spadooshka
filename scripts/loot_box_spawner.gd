class_name LootBoxSpawner extends Node3D

const ITEM_FILE_NAMES: PackedStringArray = [
	"res://scenes/item-scenes/speed_boost.tscn",
	"res://scenes/item-scenes/jump_boost.tscn",
	"res://scenes/item-scenes/grappling_hook.tscn",
	"res://scenes/item-scenes/grenade_item.tscn"
	]

@export var spawn_positions: Array[Node]
@export var num_boxes: int = 3

var loot_box_scene: PackedScene = load("res://scenes/loot_box.tscn")

func spawn() -> void:
	for i in range(num_boxes):
		var loot_box = loot_box_scene.instantiate()
		
		var random_index: int = randi_range(0, ITEM_FILE_NAMES.size() - 1)
		loot_box.item = load(ITEM_FILE_NAMES[random_index]).instantiate()
		
		random_index = randi_range(0, spawn_positions.size() - 1)
		loot_box.global_transform = spawn_positions[random_index].global_transform
		spawn_positions.remove_at(random_index)
		
		self.add_child(loot_box)
