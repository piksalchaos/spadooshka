class_name LootBox extends StaticBody3D

const ITEM_FILE_NAMES: PackedStringArray = [
	"res://scenes/item-scenes/speed_boost.tscn",
	"res://scenes/item-scenes/jump_boost.tscn",
	"res://scenes/item-scenes/grappling_hook.tscn",
	"res://scenes/item-scenes/grenade_item.tscn"
]

@export var item: Item 

func _ready() -> void:
	var random_index: int = randi_range(0, ITEM_FILE_NAMES.size() - 1)
	item = load(ITEM_FILE_NAMES[random_index]).instantiate()

func obtain_item() -> Item:
	free_for_all_peers.rpc()
	return item

@rpc("any_peer", "call_local")
func free_for_all_peers():
	queue_free()
