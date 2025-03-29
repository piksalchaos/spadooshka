class_name BilliardBomb extends RigidBody3D

const BILLIARD_BALL = preload("res://scenes/entities/item_entities/billiard_ball.tscn")
const NUMBER_OF_BALLS = 15
const BALL_SPEED = 16.0
const BALL_DISTANCE_FROM_ORIGIN = 3.0

var enabled = false

func _on_enable_timer_timeout() -> void:
	enabled = true
	if get_contact_count() > 0:
		explode()

func _on_body_entered(_body: Node) -> void:
	if enabled:
		explode()

func explode():
	for i in NUMBER_OF_BALLS:
		var vector_direction = get_random_upward_unit_vector()
		SpawnerManager.spawn_with_data({
			"path": "res://scenes/entities/item_entities/billiard_ball.tscn",
			"props": {
				"position": position + vector_direction * BALL_DISTANCE_FROM_ORIGIN,
				"linear_velocity": vector_direction * BALL_SPEED
			}
		})
	queue_free()

func get_random_upward_unit_vector():
	var theta = randf_range(0, TAU)
	var y = randf_range(0.0, 1.0)
	var r = sqrt(1.0 - y * y)
	var x = r * cos(theta)
	var z = r * sin(theta)
	return Vector3(x, y, z)
