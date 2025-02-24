class_name Player extends CharacterBody3D

@onready var camera: Camera3D = $Head/Camera
@onready var interact_cast: RayCast3D = $Head/Camera/InteractCast
@onready var dash_timer: Timer = $Timers/DashTimer
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
@onready var wall_jump_cooldown_timer: Timer = $Timers/WallJumpCooldownTimer
@onready var coyote_jump_timer: Timer = $Timers/CoyoteJumpTimer
@onready var inventory: Inventory = $Inventory
@onready var effect_manager: Node = $EffectManager

@export var equipped_gun: Gun
@export var health: int
@export var max_health = 100

signal interact(target: Object)

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

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var can_dash: bool = true
var is_dashing: bool = false
var is_wall_sliding: bool = false
var was_on_floor: bool = false

signal ammo_changed(num_bullets: int, mag_capacity: int)
signal dash_changed(dash_value: int, max_dash: int)
signal health_changed(health: int, max_health: int)
signal death(peer_id: int)
var is_speed_boosted: bool = false
var is_jump_boosted: bool = false

func _enter_tree() -> void:
	set_multiplayer_authority(str(name).to_int())

func _ready():
	set_slide_on_ceiling_enabled(false)
	
	if not is_multiplayer_authority(): return
	camera.current = true
	
@rpc("any_peer", "call_local")
func spawn(spawn_transform: Transform3D):
	transform = spawn_transform
	health = max_health
	health_changed.emit(health, max_health)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	
	if event.is_action_pressed("jump"):
		
		jump_buffer_timer = JUMP_BUFFER_TIME
	if Input.is_action_pressed("dash") and can_dash:
		dash()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if interact_cast.is_colliding():
		var target := interact_cast.get_collider()
		if Input.is_action_just_pressed("interact"):
			interact.emit(target)
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var max_speed := BOOSTED_SPEED if is_effect_applied("Speed Boost") else DEFAULT_SPEED
	var acceleration := ACCELERATION
	var deceleration := FRICTION if is_on_floor() else IN_AIR_DECELERATION
	
	if not is_dashing and wall_jump_cooldown_timer.is_stopped():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * max_speed, acceleration * delta)
			velocity.z =  lerp(velocity.z, direction.z * max_speed, acceleration * delta)
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
		#position = Vector3.ZERO
		death.emit(get_multiplayer_authority())
		
	health_changed.emit(health, max_health)

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
