class_name Player extends CharacterBody3D

@onready var camera: Camera3D = $Head/Camera
@onready var dash_timer: Timer = $Timers/DashTimer
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
@onready var wall_jump_cooldown_timer: Timer = $Timers/WallJumpCooldownTimer
@onready var inventory: Inventory = $Inventory
@onready var effect_manager: Node = $EffectManager

@export var equipped_gun: Gun
@export var health: int = 100
@export var max_health: int = 100

const DEFAULT_SPEED: float = 16.0
const BOOSTED_SPEED: float = 30.0
const DASH_SPEED: float = 50.0

const DEFAULT_JUMP_VELOCITY: float = 11.0
const BOOSTED_JUMP_VELOCITY: float = 18.0
const WALL_JUMP_VELOCITY: float = 25.0

const WALL_JUMP_Y_DIRECTION: float = 0.1
const WALL_SLIDE_GRAVITY: float = -2.0

const ACCELERATION: float = 4.0
const IN_AIR_DECELERATION: float = 2
const FRICTION: float = 10.0
const COYOTE_TIME: float = 0.15
const JUMP_BUFFER_TIME: float = 0.1

const MINIMIZED_SIZE: Vector3 = Vector3(0.5, 0.5, 0.5)
const RETURN_TO_NORMAL_SIZE: Vector3 = Vector3(1/MINIMIZED_SIZE.x, 1/MINIMIZED_SIZE.y, 1/MINIMIZED_SIZE.z)

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var can_dash: bool = true
var is_dashing: bool = false
var is_wall_sliding: bool = false
var was_on_floor: bool = false

var default_fov = 90
var dash_fov = 100
var speed_boost_fov = 95
var fov_decay_rate = 100 #how much fov wil drop by in a second

var selected_body: PhysicsBody3D
var minimized = false

signal ammo_changed(num_bullets: int, mag_capacity: int)
signal dash_changed(dash_value: int, max_dash: int)
signal health_changed(health: int, max_health: int)
signal death(peer_id: int)

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	set_slide_on_ceiling_enabled(false)
	
	if not is_multiplayer_authority(): return
	camera.current = true

@rpc("any_peer", "call_local")
func spawn(spawn_transform: Transform3D):
	global_transform = spawn_transform
	velocity = Vector3.ZERO

	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	
	health = max_health
	health_changed.emit(health, max_health)
	
	can_dash = true
	is_dashing = false
	dash_timer.stop()
	dash_cooldown_timer.stop()
	dash_changed.emit(dash_cooldown_timer.wait_time, dash_cooldown_timer.wait_time)
	
	is_wall_sliding = false
	
	inventory.spawn()
	equipped_gun.spawn()
	
	for child in get_children():
		if child is BulletHole:
			child.queue_free()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event.is_action_pressed("jump"):
		
		jump_buffer_timer = JUMP_BUFFER_TIME
	if Input.is_action_pressed("dash") and can_dash:
		dash()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if is_effect_applied("Minimizer"):
		if minimized == false:
			basis = basis.scaled(MINIMIZED_SIZE)
		minimized = true
	else:
		if minimized == true:
			basis = basis.scaled(RETURN_TO_NORMAL_SIZE)
		minimized = false
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var max_speed := BOOSTED_SPEED if is_effect_applied("Speed Boost") else DEFAULT_SPEED
	var acceleration := ACCELERATION
	var deceleration := FRICTION if is_on_floor() else IN_AIR_DECELERATION
	
	if not is_dashing and wall_jump_cooldown_timer.is_stopped():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * max_speed, acceleration * delta)
			velocity.z = lerp(velocity.z, direction.z * max_speed, acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	
	if is_on_floor() and dash_timer.is_stopped() \
	and dash_cooldown_timer.is_stopped() and not can_dash:
		dash_cooldown_timer.start()
	
	# maybe reduce horizontal velocity during wall sliding in the future
	is_wall_sliding = get_slide_collision_count() == 2 and not is_on_floor()
	if is_wall_sliding and velocity.y <= 0:
		velocity.y += WALL_SLIDE_GRAVITY * delta
	elif not is_on_floor() or (is_wall_sliding and velocity.y > 0):
		velocity += get_gravity() * delta
	
	
	# same wall slide code but you will wall slide regardless of if ur pressing against the wall or not
	#if not is_on_wall_only(): # if not on wall, dont wall slide & have regular gravity
		#is_wall_sliding = false
		#velocity += get_gravity() * delta
	#elif not is_wall_sliding and is_on_wall_only(): # if just got on wall, cancel y velo & enable sliding
		#is_wall_sliding = true
	#elif is_wall_sliding and velocity.y <= 0: # if sliding + falling back down, have less gravity
		#velocity.y += WALL_SLIDE_GRAVITY * delta
	#elif is_wall_sliding and velocity.y > 0: # if sliding + falling back down, have less gravity
		#velocity += get_gravity() * delta
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	if jump_buffer_timer > 0:
		query_jump()
		jump_buffer_timer -= delta
	
	move_and_slide()
	#stupid hack to get dash bar to immediately deplete at start of dash
	var dash_value
	if not can_dash and dash_cooldown_timer.is_stopped():
		dash_value = 0.0
	else:
		dash_value = dash_cooldown_timer.wait_time-dash_cooldown_timer.time_left
	dash_changed.emit(dash_value, dash_cooldown_timer.wait_time)
	
	update_fov(delta)

func query_jump():
	if coyote_timer > 0:
		coyote_timer = 0
		jump_buffer_timer = 0
		if is_dashing:
			is_dashing = false
			dash_timer.stop()
			dash_cooldown_timer.start()
		if is_effect_applied("Jump Boost"):
			velocity.y = BOOSTED_JUMP_VELOCITY
		else:
			velocity.y = DEFAULT_JUMP_VELOCITY
	elif is_wall_sliding:
		var direction = get_wall_normal() * 0.5
		direction.y = WALL_JUMP_Y_DIRECTION
		velocity = direction * WALL_JUMP_VELOCITY
		wall_jump_cooldown_timer.start()


func dash():
	is_dashing = true
	can_dash = false
	var dash_direction := camera.global_transform.basis.z * -1
	velocity = dash_direction * DASH_SPEED
	dash_timer.start()

@rpc("any_peer")
func receive_damage(damage):
	health -= damage
	if health <= 0:
		death.emit(get_multiplayer_authority())
		
	health_changed.emit(health, max_health)

func get_camera_global_basis() -> Basis:
	return camera.global_basis
	
func update_fov(delta):
	if is_dashing:
		camera.fov = dash_fov
		return
	if is_effect_applied("Speed Boost"):
		camera.fov = speed_boost_fov
		return
	camera.fov = max(default_fov, camera.fov - fov_decay_rate * delta)
func _on_dash_timer_timeout() -> void:
	is_dashing = false
	velocity = velocity.normalized() * DEFAULT_SPEED

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true

func _on_gun_ammo_changed(num_bullets: int, mag_capacity: int) -> void:
	ammo_changed.emit(num_bullets, mag_capacity)

func apply_effect(effect: Effect):
	effect_manager.apply_effect(effect)

func is_effect_applied(effect_name: String):
	return effect_manager.is_effect_applied(effect_name)
