class_name GrapplingHook extends Node

@onready var player: CharacterBody3D 
@onready var grapple_ray: RayCast3D = $GrappleRay

@export var grapple_range: float = 50.0
@export var rest_length: float = 2.0
@export var stiffness: float = 10.0
@export var damping: float = 1.0

var target: Vector3
var is_launched: bool = false

func _ready() -> void:
	grapple_ray.target_position = Vector3(0, 0, -range)

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_released("use_item"):
		retract()
	
	if is_launched:
		handle_grapple(delta)
		if not $GrappleSoundEffect.playing:
			$GrappleSoundEffect.play()

func launch():
	$LaunchSoundEffect.play()
	if grapple_ray.is_colliding():
		target = grapple_ray.get_collision_point()
		is_launched = true
		
func retract():
	$RetractSoundEffect.play()
	is_launched = false
		
func handle_grapple(delta):
	var target_direction = player.global_position.direction_to(target)
	var target_distance = player.global_position.distance_to(target)
	
	var displacement = target_distance - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force = stiffness * displacement * target_direction
		
		var vel_dot = player.velocity.dot(target_direction)
		var damping_force = -damping * vel_dot * target_direction
		
		force = spring_force + damping_force
		
	player.velocity += force * delta
