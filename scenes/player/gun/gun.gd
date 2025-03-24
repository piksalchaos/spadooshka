class_name Gun extends Node

@export var stats: GunStats

var is_gun_ready: bool
var num_bullets: int

@onready var shoot_ray: RayCast3D = $ShootRay

var bullet_hole = preload("res://scenes/entities/bullet_hole.tscn")
var is_reloading: bool
var is_aiming: bool
#var is_revved: bool
var is_revving: bool
var need_to_rev: bool

signal ammo_changed(num_bullets: int, mag_capacity: int)

func _ready() -> void:
	shoot_ray.target_position = Vector3(0, -stats.shoot_range, 0)
	$FireTimer.wait_time = stats.fire_time
	$ReloadTimer.wait_time = stats.reload_time
	$RevTimer.wait_time = stats.rev_time
	need_to_rev = stats.rev_time != 0

func spawn():
	is_gun_ready = true
	is_revving = false
	#is_revved = false
	is_reloading = false
	num_bullets = stats.mag_capacity
	is_reloading = false
	is_aiming = false
	ammo_changed.emit(num_bullets, stats.mag_capacity)
	
	reload()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("shoot") and stats.shoot_mode == GunStats.ShootMode.SEMI:
		shoot()
	if event.is_action_pressed("reload"):
		reload()
	
	if Input.is_action_just_pressed("aim"):
		is_aiming = true
	if Input.is_action_just_released("aim"):
		is_aiming = false

func _process(_delta) -> void:
	if Input.is_action_pressed("shoot") and stats.shoot_mode == GunStats.ShootMode.AUTO:
		if need_to_rev and not is_gun_ready and not is_revving:
			is_revving = true
			$RevTimer.start()
		shoot()
	if Input.is_action_just_released("shoot") and need_to_rev:
		is_gun_ready = false
		is_revving = false

func shoot():
	if not is_gun_ready or num_bullets == 0:
		return
	num_bullets -= 1
	is_gun_ready = false
	ammo_changed.emit(num_bullets, stats.mag_capacity)
	
	var bullet_trajectory_rot_x = stats.aim_bullet_trajectory_rot_x if is_aiming else stats.bullet_trajectory_rot_x
	var bullet_trajectory_rot_z = stats.aim_bullet_trajectory_rot_z if is_aiming else stats.bullet_trajectory_rot_z
	shoot_ray.rotation_degrees.x = randf_range(-bullet_trajectory_rot_x, bullet_trajectory_rot_x)
	shoot_ray.rotation_degrees.z = randf_range(-bullet_trajectory_rot_z, bullet_trajectory_rot_z)
	
	if shoot_ray.is_colliding():
		var target = shoot_ray.get_collider()
		var position = shoot_ray.get_collision_point()
		var normal = shoot_ray.get_collision_normal()
		
		if target.has_method("receive_damage"):
			target.receive_damage.rpc_id(target.get_multiplayer_authority(), stats.damage)
		if not target is Player:
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
	
	#play_shoot_effects()
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
	$ReloadSFX.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("reload")
	
func play_shoot_effects():
	$GunEffects.play_effects()
	$ShootSFX.play()
	$AnimationPlayer.stop()
	$AnimationPlayer.play("shoot")

func _on_fire_timer_timeout() -> void:
	is_gun_ready = true

func _on_reload_timer_timeout() -> void:
	is_gun_ready = not need_to_rev
	is_reloading = false
	num_bullets = stats.mag_capacity
	ammo_changed.emit(num_bullets, stats.mag_capacity)

func _on_rev_timer_timeout() -> void:
	is_gun_ready = true
	is_revving = false
