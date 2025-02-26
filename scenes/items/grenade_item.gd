class_name GrenadeItem extends Item

@export var speed: float = 10.0

const LAUNCH_OFFSET: Vector3 = Vector3(0, 1.5, 0)

var grenade_object = preload("res://scenes/entities/item_entities/grenade.tscn")

func use():
	var new_grenade_object: RigidBody3D = grenade_object.instantiate()
	new_grenade_object.position = LAUNCH_OFFSET + player.position
	new_grenade_object.linear_velocity = speed * -player.get_camera_global_basis()[2]
	new_grenade_object.add_collision_exception_with(player)
	get_tree().current_scene.add_child(new_grenade_object)
	queue_free()
	return true
