extends Node

@export var MAG_CAPACITY = 5

@export var num_bullets = MAG_CAPACITY
@export var is_gun_ready = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ReloadTimer.timeout.connect(func(): 
		is_gun_ready = true
		num_bullets = MAG_CAPACITY
	)
	$FireTimer.timeout.connect(func():
		is_gun_ready = true
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
	if event.is_action_pressed("reload"):
		reload()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	if not is_gun_ready:
		return
	if num_bullets == 0:
		return
	num_bullets -= 1
	is_gun_ready = false
	play_shoot_effects()
	$FireTimer.start()
	print(num_bullets)
	if num_bullets == 0:
		await $FireTimer.timeout
		reload()
		print("reload")
	else:
		pass
func reload():
	is_gun_ready = false
	$ReloadTimer.start()
	$ReloadSoundEffect.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("reload")
	
func play_shoot_effects():
	$ShootSoundEffect.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shoot")
