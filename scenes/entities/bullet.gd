class_name Bullet extends CharacterBody3D

const BULLET_HOLE = preload("res://scenes/entities/bullet_hole.tscn")
const SPEED = 120.0

@export var damage: int

func _ready():
	velocity = -global_basis.y * SPEED

func _process(delta: float) -> void:
	if not multiplayer.is_server(): return
	var collision = move_and_collide(velocity * delta)
	if collision:
		var normal = collision.get_normal()
		var collision_position = collision.get_position()
		var body = collision.get_collider()
		
		if body.has_method("receive_damage"):
			body.receive_damage.rpc_id(body.get_multiplayer_authority(), damage)
		
		if not body.is_in_group("bullet_hole_immune"):
			var random_angle = randf_range(0, PI * 2)
			var new_bullet_hole = BULLET_HOLE.instantiate()
			var scale = new_bullet_hole.transform.basis.get_scale() #have to do stupid shit to preserve scaling
			new_bullet_hole.transform = Transform3D(Basis(), collision_position + normal * 0.01) #add normal to prevent z fighting issues
			body.add_child(new_bullet_hole)
			if abs(normal.dot(Vector3.RIGHT)) == 1:
				new_bullet_hole.global_transform = new_bullet_hole.transform.looking_at(collision_position + normal, Vector3.FORWARD.rotated(normal, random_angle))
			else:
				new_bullet_hole.global_transform = new_bullet_hole.transform.looking_at(collision_position + normal, Vector3.RIGHT.rotated(normal, random_angle))
			new_bullet_hole.global_transform = new_bullet_hole.global_transform.scaled_local(scale)
			
			SpawnerManager.spawn_with_data({
				"path": "res://scenes/entities/bullet_hole.tscn",
				"props": {
					"global_transform": new_bullet_hole.global_transform
				}
			})
			
			new_bullet_hole.queue_free()
		queue_free()

func _on_free_timer_timeout() -> void:
	if not multiplayer.is_server(): return
	queue_free()
