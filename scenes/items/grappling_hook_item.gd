class_name GrapplingHookItem extends Item

const GRAPPLING_HOOK_SCENE = preload("res://scenes/entities/item_entities/grappling_hook.tscn")

var is_waiting_for_launch_attempt = false

var grappling_hook

#stupid way to circumvent the fact that launches may be unsuccessful
func _ready():
	grappling_hook = GRAPPLING_HOOK_SCENE.instantiate()
	grappling_hook.set_player(player)
	player.camera.add_child(grappling_hook)
	
func use() -> bool:
	var is_launch_successful = grappling_hook.launch()
	if is_launch_successful:
		queue_free()
		return true
	return false
	
	
