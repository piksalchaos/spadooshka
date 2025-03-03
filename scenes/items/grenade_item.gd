class_name GrenadeItem extends Item

@export var speed: float = 30

const LAUNCH_OFFSET: Vector3 = Vector3(0, 1.5, 0)

var grenade_object = preload("res://scenes/entities/item_entities/grenade.tscn")
@onready var trajectory = $Trajectory
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _process(float) -> void:
	var camera_basis = player.get_camera_global_basis()
	var launch_vector = camera_basis[2]
	trajectory.a = -gravity * 0.5 / (speed ** 2) * (launch_vector.x ** 2 + launch_vector.z ** 2)
	trajectory.b = launch_vector.y / speed * sqrt(launch_vector.x ** 2 + launch_vector.z ** 2)
	trajectory.position = player.position + LAUNCH_OFFSET
	trajectory.global_basis = Basis(camera_basis[2], Vector3.UP, camera_basis[0]).orthonormalized()

func use():
	var new_grenade_object: RigidBody3D = grenade_object.instantiate()
	new_grenade_object.position = LAUNCH_OFFSET + player.position
	new_grenade_object.linear_velocity = speed * -player.get_camera_global_basis()[2]
	new_grenade_object.add_collision_exception_with(player)
	get_tree().current_scene.add_child(new_grenade_object)
	queue_free()
	return true
