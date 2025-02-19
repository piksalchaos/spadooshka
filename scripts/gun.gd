class_name Gun extends Node

@export var MAG_CAPACITY = 5
@export var num_bullets = MAG_CAPACITY

@export var damage = 20
@export var is_gun_ready = true

@export var shoot_range = 100

@onready var shoot_ray = $ShootRay

enum ShootMode {AUTO, SEMI}
@export var shoot_mode: ShootMode

var bullet_hole = preload("res://scenes/bullet_hole.tscn")
var is_reloading = false

signal ammo_changed(num_bullets: int, mag_capacity: int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shoot_ray.target_position = Vector3(0, -shoot_range, 0)

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("shoot") and shoot_mode == ShootMode.SEMI:
		shoot()
	if event.is_action_pressed("reload"):
		reload()

func _process(_delta) -> void:
	if Input.is_action_pressed("shoot") and shoot_mode == ShootMode.AUTO:
		shoot()
func shoot():
	if not is_gun_ready:
		return
	if num_bullets == 0:
		return
	num_bullets -= 1
	is_gun_ready = false
	ammo_changed.emit(num_bullets, MAG_CAPACITY)

	if shoot_ray.is_colliding():
		var target = shoot_ray.get_collider().get_parent()
		var position = shoot_ray.get_collision_point()
		var normal = shoot_ray.get_collision_normal()
		
		if target.has_method("receive_damage"):
			target.receive_damage(damage)
		
		var random_angle = randf_range(0, PI * 2)
		var new_bullet_hole = bullet_hole.instantiate()
		var scale = new_bullet_hole.transform.basis.get_scale() #have to do stupid shit to preserve scaling
		new_bullet_hole.transform = Transform3D(Basis(), position + normal * 0.01) #add normal to prevent z fighting issues
		target.add_child(new_bullet_hole)
		if abs(normal.dot(Vector3.RIGHT)) == 1:
			new_bullet_hole.global_transform = new_bullet_hole.transform.looking_at(position + normal, Vector3.FORWARD.rotated(normal, random_angle))
		else:
			new_bullet_hole.global_transform = new_bullet_hole.transform.looking_at(position + normal, Vector3.RIGHT.rotated(normal, random_angle))
		new_bullet_hole.global_transform = new_bullet_hole.global_transform.scaled_local(scale)
	
	play_shoot_effects()
	$FireTimer.start()
	if num_bullets == 0:
		await $FireTimer.timeout
		reload()
	else:
		pass
func reload():
	if is_reloading:
		return
	is_gun_ready = false
	is_reloading = true
	$ReloadTimer.start()
	$ReloadSoundEffect.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("reload")
	
func play_shoot_effects():
	$GunEffects.play_effects()
	$ShootSoundEffect.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shoot")


func _on_fire_timer_timeout() -> void:
	is_gun_ready = true

func _on_reload_timer_timeout() -> void:
	is_gun_ready = true
	is_reloading = false
	num_bullets = MAG_CAPACITY
	ammo_changed.emit(num_bullets, MAG_CAPACITY)
