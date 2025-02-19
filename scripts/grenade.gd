extends RigidBody3D

@export var max_damage = 100
@export var max_damage_range = 0.1
@export var range = 10
@export var falloff_strength = 2

@export var time_to_explode = 3
@export var damage_to_force_factor = 5

func calculate_damage(distance) -> float:
	if distance < max_damage_range:
		return max_damage
	return (max_damage_range/distance) ** falloff_strength * max_damage
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ExplodeTimer.wait_time = time_to_explode
	$ExplosionArea/CollisionShape3D.shape.radius = range


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_explode_timer_timeout() -> void:
	var bodies = $ExplosionArea.get_overlapping_bodies()
	for body in bodies:
		if body is StaticBody3D:
			continue
		var difference_vector = body.position - position
		if body is CharacterBody3D:
			body.velocity += difference_vector.normalized() * calculate_damage(difference_vector.length()) * damage_to_force_factor
			continue
		body.apply_impulse(difference_vector.normalized() * calculate_damage(difference_vector.length()) * damage_to_force_factor)
	queue_free()
