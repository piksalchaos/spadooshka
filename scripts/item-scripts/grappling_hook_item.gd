class_name GrapplingHookItem extends Item

const GRAPPLING_HOOK_SCENE = preload("res://scenes/grappling_hook.tscn")

func use() -> bool:
	var grappling_hook = GRAPPLING_HOOK_SCENE.instantiate()
	grappling_hook.set_player(player)
	player.camera.add_child(grappling_hook)
	queue_free()
	return true
