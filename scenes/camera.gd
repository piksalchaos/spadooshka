extends Camera3D

@onready var player: CharacterBody3D = $"../.."
@onready var head: Node3D = $".."
@onready var camera_collider: RayCast3D = $"../CameraCollider"


const MOUSE_SENSITIVITY = 0.005

var DEFAULT_CAMERA_POSITION = Vector3(0.711, 0.431, 2.059)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	position = DEFAULT_CAMERA_POSITION
	camera_collider.target_position = DEFAULT_CAMERA_POSITION

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _unhandled_input(event: InputEvent) -> void:	
	if event is InputEventMouseMotion:
		player.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -60, 60)

func _process(delta: float) -> void:
	if camera_collider.is_colliding():
		global_transform.origin = camera_collider.get_collision_point()
	else:
		position = DEFAULT_CAMERA_POSITION
