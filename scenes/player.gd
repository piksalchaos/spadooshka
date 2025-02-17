class_name Player extends CharacterBody3D

@onready var camera: Camera3D = $Camera
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interact_cast: RayCast3D = $Camera/InteractCast
@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var dash_timer: Timer = $DashTimer
@onready var dash_cooldown_timer: Timer = $DashCooldownTimer


var items: Array[Item] = []
var selected_item_slot = 0
var is_speed_boosted: bool = false
var can_dash: bool = true
var is_dashing: bool = false

const MAX_ITEM_COUNT: int = 3
const DEFAULT_SPEED: float = 10.0
const BOOSTED_SPEED: float = 16.0
const DASH_SPEED: float = 50.0
const DEFAULT_JUMP_VELOCITY: float = 7.0
const BOOSTED_JUMP_VELOCITY: float = 12.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * .005)
		camera.rotate_x(-event.relative.y * 0.005)
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)
	
	if event.is_action_pressed("shoot"):
		play_shoot_effects()
	
	if event.is_action_pressed("use_item") and items.size() > 0:
		call(items[selected_item_slot].player_function_name)
	
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = DEFAULT_JUMP_VELOCITY
	
	#if event.is_action_pressed("dash"):
		#velocity = -camera.global_transform.basis.z * DASH_SPEED
	
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
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var speed = BOOSTED_SPEED if is_speed_boosted else DEFAULT_SPEED
	
	if not is_dashing:
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

	if animation_player.current_animation == "shoot":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		animation_player.play("move")
	else:
		animation_player.play("idle")
	
	# press dash
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			is_dashing = true
			var dash_direction := camera.global_transform.basis.z * -1
			velocity = dash_direction * DASH_SPEED
			dash_timer.start()
			can_dash = false
		
	move_and_slide()

func play_shoot_effects():
	animation_player.stop()
	animation_player.play("shoot")

func boost_speed():
	speed_boost_timer.start()
	is_speed_boosted = true

func _on_speed_boost_timer_timeout() -> void:
	is_speed_boosted = false

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	if dash_cooldown_timer.is_stopped() and not can_dash:
		velocity = Vector3.ZERO
		dash_cooldown_timer.start()

func _on_dash_cooldown_timer_timeout() -> void:
	can_dash = true
