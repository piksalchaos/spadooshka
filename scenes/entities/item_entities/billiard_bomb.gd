class_name BilliardBomb extends RigidBody3D

const NUMBER_OF_BALLS = 15
const BALL_SPEED = 18.0
const BALL_DISTANCE_FROM_ORIGIN = 1.0
const BALL_RANGE = PI/3

var enabled = false

func _on_enable_timer_timeout() -> void:
	enabled = true

func explode(vector_direction: Vector3):
	for i in NUMBER_OF_BALLS:
		var offset_vector_direction = get_randomly_offset_vector(vector_direction, BALL_RANGE)
		SpawnerManager.spawn_with_data({
			"path": "res://scenes/entities/item_entities/billiard_ball.tscn",
			"props": {
				"position": position + offset_vector_direction * BALL_DISTANCE_FROM_ORIGIN,
				"linear_velocity": offset_vector_direction * BALL_SPEED,
				"rotation": Vector3(randf()*2*PI, randf()*2*PI, randf()*2*PI),
				"texture_index": i
			}
		})
	queue_free()

func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	if not enabled: return
	for i in range(state.get_contact_count()):
		var normal = state.get_contact_local_normal(i)
		explode(normal)

func get_randomly_offset_vector(vector: Vector3, max_angle: float) -> Vector3:
	var rotation_x = get_randomly_rotated_quat(Vector3.RIGHT, max_angle)
	var rotation_y = get_randomly_rotated_quat(Vector3.UP, max_angle)
	var rotation_z = get_randomly_rotated_quat(Vector3.BACK, max_angle)
	return (vector * rotation_x * rotation_y * rotation_z).normalized()

func get_randomly_rotated_quat(axis, max_angle):
	return Quaternion(axis, randf_range(-max_angle/2, max_angle/2))
