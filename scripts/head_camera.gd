extends Node3D

@onready var player: CharacterBody3D = $".."
@onready var camera: Camera3D = $Camera
@onready var camera_collider: RayCast3D = $CameraCollider

const MOUSE_SENSITIVITY = 0.005

var DEFAULT_CAMERA_POSITION = Vector3(0.711, 0.431, 2.059)

func _ready() -> void:
	if not is_multiplayer_authority(): return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.position = DEFAULT_CAMERA_POSITION
	camera_collider.target_position = DEFAULT_CAMERA_POSITION
	camera_collider.add_exception_rid(player)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed('escape'):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		player.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		self.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		self.rotation_degrees.x = clamp(self.rotation_degrees.x, -60, 60)	

func _physics_process(delta: float) -> void:
	if camera_collider.is_colliding():
		camera.global_transform.origin = camera_collider.get_collision_point()
	else:
		camera.position = DEFAULT_CAMERA_POSITION
