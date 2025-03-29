class_name LootBox extends StaticBody3D

const ITEM_FILE_NAMES: PackedStringArray = [
	"res://scenes/items/speed_boost_item.tscn",
	"res://scenes/items/jump_boost_item.tscn",
	"res://scenes/items/grappling_hook_item.tscn",
	"res://scenes/items/grenade_item.tscn",
	"res://scenes/items/health_burger_item.tscn",
	"res://scenes/items/minimizer_item.tscn",
	"res://scenes/items/billiard_bomb_item.tscn"
]

@export var item: Item
@export var interaction_component: InteractionComponent

func _ready() -> void:
	var random_index: int = randi_range(0, ITEM_FILE_NAMES.size() - 1)
	#item = load(ITEM_FILE_NAMES[random_index]).instantiate()
	item = load("res://scenes/items/billiard_bomb_item.tscn").instantiate()

func obtain_item() -> Item:
	queue_free_for_all_peers.rpc()
	return item

@rpc("any_peer", "call_local", "reliable")
func queue_free_for_all_peers():
	queue_free()
