class_name BilliardBombItem extends Item
const BILLIARD_BOMB = preload("res://scenes/entities/item_entities/billiard_bomb.tscn")
const SPEED = 18.0
const LAUNCH_OFFSET: Vector3 = Vector3(0, 1.5, 0)
const VELOCITY_OFFSET: Vector3 = Vector3(0, 5.0, 0)

func use():
	print('spawned billiard bomb')
	print(player.get_multiplayer_authority())
	SpawnerManager.spawn_with_data({
		"path": "res://scenes/entities/item_entities/billiard_bomb.tscn",
		"props": {
			"position": player.position + LAUNCH_OFFSET,
			"rotation": Vector3(randf()*2*PI, randf()*2*PI, randf()*2*PI),
			"linear_velocity": -player.get_camera_global_basis().z * SPEED + VELOCITY_OFFSET
		},
		"server_rpc": {
			"add_collision_exception_with_remotely": {
				"exception_path": player.get_path()
			}
		}
	})
	queue_free()
	return true
