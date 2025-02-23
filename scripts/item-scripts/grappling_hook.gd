class_name GrapplingHook extends Item

@onready var grapple_ray: RayCast3D = $GrappleRay
@onready var rope: Rope = $Rope

@onready var launch_sfx: AudioStreamPlayer = $LaunchSFX
@onready var retract_sfx: AudioStreamPlayer = $RetractSFX
@onready var grapple_sfx: AudioStreamPlayer = $GrappleSFX

@export var grapple_range: float = 50.0
@export var rest_length: float = 2.0
@export var stiffness: float = 10.0
@export var damping: float = 1.0

var target: Vector3
var is_launched: bool = false

func _ready() -> void:
	grapple_ray.target_position = Vector3(0, 0, -grapple_range)

func use() -> bool:
	return launch()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if is_launched:
		if not grapple_sfx.playing:
			grapple_sfx.play()
		handle_grapple(delta)
		if Input.is_action_just_released("use_item"):
			retract()

func launch():
	launch_sfx.play()
	if not grapple_ray.is_colliding(): return false
	target = grapple_ray.get_collision_point()
	is_launched = true
	rope.reparent(get_tree().current_scene)
	rope.visible = true
	return true
		
func retract():
	retract_sfx.play()
	is_launched = false
	rope.queue_free()
	self.queue_free()
		
func handle_grapple(delta):
	var target_direction = player.global_position.direction_to(target)
	var target_distance = player.global_position.distance_to(target)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(global_position, target)
	query.exclude = [player]
	var result = space_state.intersect_ray(query)
	if result and result.position.distance_to(target) > 0.1:
		retract()
		return
	var displacement = target_distance - rest_length
	
	var force = Vector3.ZERO
	
	if displacement > 0:
		var spring_force = stiffness * displacement * target_direction
		
		var vel_dot = player.velocity.dot(target_direction)
		var damping_force = -damping * vel_dot * target_direction
		
		force = spring_force + damping_force
		
	player.velocity += force * delta
	
	rope.end = target
	rope.start = player.position
