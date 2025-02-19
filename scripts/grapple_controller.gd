extends Node

@onready var player = $"../.."
@onready var ray: RayCast3D = $"../../Head/Camera/GrappleRay"

const REST_LENGTH: float = 2.0
const STIFFNESS: float = 10.0
var damping: float = 1.0

var target: Vector3
var is_launched: bool = false

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_released("use_item"):
		retract()
	
	if is_launched:
		handle_grapple(delta)

func launch():
	if ray.is_colliding():
		target = ray.get_collision_point()
		is_launched = true
		
func retract():
	is_launched = false
		
func handle_grapple(delta):
	var target_direction = player.global_position.direction_to(target)
	var target_distance = player.global_position.distance_to(target)
	
	var displacement = target_distance - REST_LENGTH
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force = STIFFNESS * displacement * target_direction
		
		var vel_dot = player.velocity.dot(target_direction)
		var damping = -damping * vel_dot * target_direction
		
		force = spring_force + damping
		
	player.velocity += force * delta
