class_name Player extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var interact_cast: RayCast3D = $Head/Camera/InteractCast
@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@export var equipped_gun: Gun
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer

const MAX_ITEM_COUNT: int = 3
const DEFAULT_SPEED: float = 10.0
const BOOSTED_SPEED: float = 100.0
const DASH_SPEED: float = 50.0

const DEFAULT_JUMP_VELOCITY: float = 7.0
const BOOSTED_JUMP_VELOCITY: float = 12.0
const WALL_JUMP_VELOCITY: float = 30.0
const WALL_JUMP_Y_DIRECTION: float = 0.2

const MOUSE_SENSITIVITY = 0.005
const ACCELERATION: float = 5.0
const FRICTION: float = 15.0

var items: Array[Item] = []
var selected_item_slot = 0
var is_speed_boosted: bool = false
var can_dash: bool = true
var is_dashing: bool = false
var is_wall_sliding: bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		head.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -60, 60)
	
	if event.is_action_pressed("jump"):
		jump()
	 
	if event.is_action_pressed("use_item") and items.size() > 0:
		call(items[selected_item_slot].player_function_name)
	
	if items.size() > 0:
		if event.is_action_pressed("item_slot_right"):
			selected_item_slot = (selected_item_slot + 1) % items.size()
		if event.is_action_pressed("item_slot_left"):
			selected_item_slot = (selected_item_slot + items.size()-1) % items.size()

func _physics_process(delta: float) -> void:
	#print(selected_item_slot)
	if interact_cast.is_colliding():
		#change this block of code later so it works well with all kinds of interactables
		var target = interact_cast.get_collider()
		if target is LootBox:
			if Input.is_action_just_pressed("interact") and items.size() < MAX_ITEM_COUNT:
				items.append(target.obtain_item())
	
	is_wall_sliding = is_on_wall_only()
	
	if is_wall_sliding:
		velocity.y += -3 * delta
	elif not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = BOOSTED_SPEED if is_speed_boosted else DEFAULT_SPEED
	
	if not is_dashing:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, ACCELERATION * delta)
			velocity.z =  lerp(velocity.z, direction.z * speed, ACCELERATION * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, FRICTION * delta)
			velocity.z = lerp(velocity.z, 0.0, FRICTION * delta)
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
		
	move_and_slide()

func boost_speed():
	speed_boost_timer.start()
	is_speed_boosted = true
	
func jump():
	if is_on_floor():
		velocity.y = DEFAULT_JUMP_VELOCITY
	elif is_wall_sliding:
		var dir = get_wall_normal()
		dir.y = WALL_JUMP_Y_DIRECTION
		velocity = dir * WALL_JUMP_VELOCITY
	
func dash():
	is_dashing = true
	var dash_direction := camera.global_transform.basis.z * -1
	velocity = dash_direction * DASH_SPEED
	dash_timer.start()
	can_dash = false

func _on_speed_boost_timer_timeout() -> void:
	is_speed_boosted = false

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	if dash_cooldown_timer.is_stopped() and not can_dash:
		velocity = Vector3.ZERO
		dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
