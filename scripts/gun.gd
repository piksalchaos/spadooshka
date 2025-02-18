class_name Gun extends Node

@export var MAG_CAPACITY = 5

@export var num_bullets = MAG_CAPACITY
@export var is_gun_ready = true

@export var range = 100

var bullet_hole = preload("res://scenes/bullet_hole.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ShootRay.target_position = Vector3(0, -range, 0)
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
	
	var target = $ShootRay.get_collider()
	var position: Vector3 = $ShootRay.get_collision_point()
	var normal: Vector3 = $ShootRay.get_collision_normal()
	
	var random_angle = randf_range(0, PI * 2)
	var new_bullet_hole = bullet_hole.instantiate()
	new_bullet_hole.transform = Transform3D(Basis(), position).looking_at(position + normal, Vector3.RIGHT.rotated(normal, random_angle))
	get_tree().current_scene.add_child(new_bullet_hole)
	
	play_shoot_effects()
	$FireTimer.start()
	if num_bullets == 0:
		await $FireTimer.timeout
		reload()
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
