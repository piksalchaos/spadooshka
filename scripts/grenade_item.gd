class_name GrenadeItem extends Item

@export var speed: float = 10.0
@export var launch_offset: Vector3

var grenade_object = preload("res://scenes/grenade.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func use():
	var new_grenade_object: RigidBody3D = grenade_object.instantiate()
	new_grenade_object.position = launch_offset + player.position
	new_grenade_object.linear_velocity = speed * -global_transform.basis[2]
	new_grenade_object.add_collision_exception_with(player)
	get_tree().current_scene.add_child(new_grenade_object)
	queue_free()
