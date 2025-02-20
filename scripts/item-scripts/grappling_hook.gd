class_name GrapplingHook extends Item

@onready var grapple_ray: RayCast3D = $GrappleRay
@onready var line_of_sight_ray: RayCast3D = $GrappleLineOfSightCheck
@onready var rope: Rope = $Rope

@export var grapple_range: float = 50.0
@export var rest_length: float = 2.0
@export var stiffness: float = 10.0
@export var damping: float = 1.0

@export var origin_offset: Vector3

var target: Vector3
var is_launched: bool = false

func _ready() -> void:
	grapple_ray.target_position = Vector3(0, 0, -grapple_range)
	line_of_sight_ray.add_exception(player)

func use() -> bool:
	return launch()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_released("use_item"):
		retract()
	
	if is_launched:
		if not $GrappleSFX.playing:
			$GrappleSFX.play()
		handle_grapple(delta)

func launch():
	$LaunchSFX.play()
	if grapple_ray.is_colliding():
		target = grapple_ray.get_collision_point()
		is_launched = true
	rope.reparent(get_tree().current_scene)
	rope.visible = true
	return is_launched
		
func retract():
	$RetractSFX.play()
	is_launched = false
	rope.queue_free()
	self.queue_free()
		
func handle_grapple(delta):
	var target_direction = player.global_position.direction_to(target)
	var target_distance = player.global_position.distance_to(target)
	
	line_of_sight_ray.target_position = target
	line_of_sight_ray.global_position = player.global_position + origin_offset
	line_of_sight_ray.force_raycast_update()
	if line_of_sight_ray.is_colliding():
		print("ahhhh")
		retract()
	var displacement = target_distance - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force = stiffness * displacement * target_direction
		
		var vel_dot = player.velocity.dot(target_direction)
		var damping_force = -damping * vel_dot * target_direction
		
		force = spring_force + damping_force
		
	player.velocity += force * delta
	
	rope.end = target
	rope.start = player.position + origin_offset
