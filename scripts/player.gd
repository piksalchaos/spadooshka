class_name Player extends CharacterBody3D

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera
@onready var interact_cast: RayCast3D = $Head/Camera/InteractCast
@onready var speed_boost_timer: Timer = $Timers/SpeedBoostTimer
@onready var dash_timer: Timer = $Timers/DashTimer
@onready var dash_cooldown_timer: Timer = $Timers/DashCooldownTimer
@export var equipped_gun: Gun

const MAX_ITEM_COUNT: int = 3
const DEFAULT_SPEED: float = 10.0
const BOOSTED_SPEED: float = 100.0
const DASH_SPEED: float = 50.0

const DEFAULT_JUMP_VELOCITY: float = 8.0
const BOOSTED_JUMP_VELOCITY: float = 12.0
const WALL_JUMP_VELOCITY: float = 20.0
const WALL_JUMP_Y_DIRECTION: float = 0.2
const WALL_SLIDE_GRAVITY: float = -2.0

const ACCELERATION: float = 2.0
const IN_AIR_DECELERATION: float = 0.5
const FRICTION: float = 10.0

var items: Array[Item] = []
var selected_item_slot = 0
var is_speed_boosted: bool = false
var can_dash: bool = true
var is_dashing: bool = false
var is_wall_sliding: bool = false

func _ready() -> void:
	set_slide_on_ceiling_enabled(false)

func _unhandled_input(event: InputEvent) -> void:	
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
	if interact_cast.is_colliding():
		#change this block of code later so it works well with all kinds of interactables
		var target = interact_cast.get_collider()
		if target is LootBox:
			if Input.is_action_just_pressed("interact") and items.size() < MAX_ITEM_COUNT:
				items.append(target.obtain_item())
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var max_speed = BOOSTED_SPEED if is_speed_boosted else DEFAULT_SPEED
	var deceleration = FRICTION if is_on_floor() else IN_AIR_DECELERATION
	
	if not is_dashing:
		if direction:
			velocity.x = lerp(velocity.x, direction.x * max_speed, ACCELERATION * delta)
			velocity.z =  lerp(velocity.z, direction.z * max_speed, ACCELERATION * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, deceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, deceleration * delta)
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
	
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
	
	move_and_slide()

func boost_speed():
	speed_boost_timer.start()
	is_speed_boosted = true
	
func jump():
	if is_on_floor():
		velocity.y = DEFAULT_JUMP_VELOCITY
	elif is_wall_sliding:
		var direction = get_wall_normal() * 0.5
		direction.y = WALL_JUMP_Y_DIRECTION
		velocity = direction * WALL_JUMP_VELOCITY
	
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
