extends Node

@export var MAG_CAPACITY = 31

@export var num_bullets = MAG_CAPACITY
@export var is_gun_active = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ReloadTimer.timeout.connect(func(): 
		is_gun_active = true
		num_bullets = MAG_CAPACITY
	)
	$FireTimer.timeout.connect(func(): is_gun_active = true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
	if event.is_action_pressed("reload"):
		reload()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	if not is_gun_active:
		return
	if num_bullets == 0:
		return
	num_bullets -= 1
	is_gun_active = false
	play_shoot_effects()
	if num_bullets == 0:
		reload()
	else:
		$FireTimer.start()
		
func reload():
	$ReloadTimer.start()
	$AnimationPlayer.play("gun/reload")
	
func play_shoot_effects():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("gun/shoot")
