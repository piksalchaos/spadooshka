class_name BilliardBombItem extends Item
const BILLIARD_BOMB = preload("res://scenes/entities/item_entities/billiard_bomb.tscn")
const SPEED = 18.0
const LAUNCH_OFFSET: Vector3 = Vector3(0, 1.5, 0)
const VELOCITY_OFFSET: Vector3 = Vector3(0, 5.0, 0)

func use():
	#var bomb = BILLIARD_BOMB.instantiate()
	#bomb.position = player.position + LAUNCH_OFFSET
	#bomb.linear_velocity = -player.get_camera_global_basis().z * SPEED + VELOCITY_OFFSET
	#bomb.add_collision_exception_with(player)
	#SpawnerManager.add_child_to_multiplayer_container(bomb)
	#spawn_bomb.rpc_id(1)
	SpawnerManager.spawn_with_data({
		"path": "res://scenes/entities/item_entities/billiard_bomb.tscn",
		"props": {
			"position": player.position + LAUNCH_OFFSET,
			"rotation": Vector3(randf()*2*PI, randf()*2*PI, randf()*2*PI),
			"linear_velocity": -player.get_camera_global_basis().z * SPEED + VELOCITY_OFFSET
		},
		"methods": {
			"add_collision_exception_with": [player]
		}
	})
	queue_free()
	return true

@rpc("any_peer", "call_local", "reliable")
func spawn_bomb():
	var bomb = load("res://scenes/entities/item_entities/billiard_bomb.tscn").instantiate()
	bomb.position = player.position + LAUNCH_OFFSET
	bomb.linear_velocity = -player.get_camera_global_basis().z * SPEED + VELOCITY_OFFSET
	bomb.add_collision_exception_with(player)
	SpawnerManager.add_child_to_multiplayer_container(bomb)
