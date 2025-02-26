extends MultiplayerSpawner

@export var num_boxes: int = 3

var loot_box_scene: PackedScene = preload("res://scenes/entities/loot_box.tscn")

func spawn_loot_boxes(spawn_transforms: Array[Transform3D]) -> void:
	var indices: Array = range(spawn_transforms.size())
	indices.shuffle()
	
	for i in range(num_boxes):
		var loot_box: LootBox = loot_box_scene.instantiate()
		loot_box.global_transform = spawn_transforms[indices.pop_back()]
		
		add_child(loot_box, true)

func despawn_loot_boxes() -> void:
	for loot_box: LootBox in get_children():
		loot_box.queue_free_for_all_peers()
