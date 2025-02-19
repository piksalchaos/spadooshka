extends Node3D

const NUM_BOXES: int = 3
const ITEM_FILE_NAMES: Array[String] = [
	"res://scenes/item-scenes/speed_boost.tscn",
	"res://scenes/item-scenes/jump_boost.tscn",
	"res://scenes/item-scenes/grappling_hook.tscn",
	"res://scenes/item-scenes/grenade_item.tscn"
	]
const SPAWN_POSITIONS: PackedVector3Array = [
	Vector3(8.338, .5, -2.493),
	Vector3(8.338, .5, 4.042),
	Vector3(-3.242, -1.71, 4.042),
	Vector3(7.323, -1.71, 11.972)
] # this can change according to map

var loot_box_scene: PackedScene = load("res://scenes/loot_box.tscn")

func _ready() -> void:
	for i in range(NUM_BOXES):
		var loot_box = loot_box_scene.instantiate()
		loot_box.item = load(ITEM_FILE_NAMES.pick_random()).instantiate()
		var random_pos_index: int = randi_range(0, SPAWN_POSITIONS.size() - 1)
		loot_box.position = SPAWN_POSITIONS[random_pos_index]
		SPAWN_POSITIONS.remove_at(random_pos_index)
		self.add_child(loot_box)
