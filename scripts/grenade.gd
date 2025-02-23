extends RigidBody3D

@export var max_damage = 100
@export var max_damage_range = 0.4
@export var grenade_range = 10
@export var falloff_strength = 2

@export var time_to_explode = 3
@export var damage_to_force_factor = 1

@export var flashing_frequency_multiplier = 5
@export var flashing_frequency_exponent = 2 #1 for pure sine wave, >1 for increasing oscillation speed

@onready var explode_timer = $ExplodeTimer

@onready var light_energy = $Light.light_energy

func calculate_damage(distance) -> float:
	if distance < max_damage_range:
		return max_damage
	return (max_damage_range/distance) ** falloff_strength * max_damage
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode_timer.wait_time = time_to_explode
	$ExplosionArea/CollisionShape3D.shape.radius = grenade_range

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#oscillate light brightness cuz it looks nice
	#$Light.light_energy = sin(1/(explode_timer.wait_time * flashing_frequency_multiplier))
	$Light.light_energy = 0.5 * light_energy * (cos(flashing_frequency_multiplier * (time_to_explode - explode_timer.time_left) ** flashing_frequency_exponent) + 1)

func _on_explode_timer_timeout() -> void:
	var bodies = $ExplosionArea.get_overlapping_bodies()
	for body in bodies:
		if body is StaticBody3D:
			continue
		var difference_vector = body.position - position
		var damage = calculate_damage(difference_vector.length())
		if body is Player:
			print(damage)
			body.receive_damage(damage)
			#vector3.up addition is stupid hack bc player's position based on feet
			body.velocity += (difference_vector + Vector3.UP).normalized() * damage * damage_to_force_factor
			continue
		body.apply_impulse(difference_vector.normalized() * damage * damage_to_force_factor)
	queue_free()
