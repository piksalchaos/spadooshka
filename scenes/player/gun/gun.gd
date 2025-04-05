class_name Gun extends Node3D

const BULLET_GUN_DISTANCE = 3.0
@export var stats: GunStats
@export var gun_model: Node3D

var is_gun_ready: bool
var num_bullets: int

@onready var shoot_ray: RayCast3D = $ShootRay
@onready var animation_player: AnimationPlayer = gun_model.get_node("AnimationPlayer")
@onready var gun_effects = gun_model.get_node("GunEffects")

var is_reloading: bool
var need_to_rev: bool
var is_revving: bool

signal ammo_changed(num_bullets: int, mag_capacity: int)
signal shot()

func _ready() -> void:
	shoot_ray.target_position = Vector3(0, -stats.shoot_range, 0)
	$FireTimer.wait_time = stats.fire_time
	$ReloadTimer.wait_time = stats.reload_time
	$RevTimer.wait_time = stats.rev_time
	need_to_rev = stats.rev_time != 0

func spawn():
	is_gun_ready = true
	is_revving = false
	is_reloading = false
	num_bullets = stats.mag_capacity
	is_reloading = false
	ammo_changed.emit(num_bullets, stats.mag_capacity)
	
	reload()

func _unhandled_input(event: InputEvent) -> void:
	if not is_multiplayer_authority(): return
	if event.is_action_pressed("shoot") and stats.shoot_mode == GunStats.ShootMode.SEMI:
		shoot()
	if event.is_action_pressed("reload"):
		reload()

func _process(_delta) -> void:
	if not is_multiplayer_authority(): return
	if Input.is_action_pressed("shoot") and stats.shoot_mode == GunStats.ShootMode.AUTO:
		shoot()
	if Input.is_action_just_pressed("shoot") and need_to_rev:
		rev()
	if Input.is_action_just_released("shoot") and need_to_rev:
		unrev()

func shoot():
	if not is_gun_ready or num_bullets == 0: 
		return
	num_bullets -= 1
	is_gun_ready = false
	ammo_changed.emit(num_bullets, stats.mag_capacity)
	
	play_shoot_effects()
	shot.emit()
	$FireTimer.start()
	if num_bullets == 0:
		await $FireTimer.timeout
		reload()
	
	var is_aiming = Input.is_action_pressed("aim")
	var bullet_trajectory_rot_x = stats.aim_bullet_trajectory_rot_x if is_aiming else stats.bullet_trajectory_rot_x
	var bullet_trajectory_rot_z = stats.aim_bullet_trajectory_rot_z if is_aiming else stats.bullet_trajectory_rot_z
	shoot_ray.rotation_degrees.x = randf_range(-bullet_trajectory_rot_x, bullet_trajectory_rot_x)
	shoot_ray.rotation_degrees.z = randf_range(-bullet_trajectory_rot_z, bullet_trajectory_rot_z)
	get_path()
	SpawnerManager.spawn_with_data({
		"path": "res://scenes/entities/bullet.tscn",
		"props": {
			"position": global_position - shoot_ray.global_basis.y * BULLET_GUN_DISTANCE,
			"rotation": shoot_ray.global_rotation,
			"damage": stats.damage
		}
	})
	
	#if shoot_ray.is_colliding():
		#var target = shoot_ray.get_collider()
		#if not is_instance_valid(target): return
		#var position = shoot_ray.get_collision_point()
		#var normal = shoot_ray.get_collision_normal()
		#
		#if not target.is_in_group("bullet_hole_immune"):
			#var random_angle = randf_range(0, PI * 2)
			#var new_bullet_hole = bullet_hole.instantiate()
			#var scale = new_bullet_hole.transform.basis.get_scale() #have to do stupid shit to preserve scaling
			#new_bullet_hole.transform = Transform3D(Basis(), position + normal * 0.01) #add normal to prevent z fighting issues
			#target.add_child(new_bullet_hole)
			#if abs(normal.dot(Vector3.RIGHT)) == 1:
				#new_bullet_hole.global_transform = new_bullet_hole.transform.looking_at(position + normal, Vector3.FORWARD.rotated(normal, random_angle))
			#else:
				#new_bullet_hole.global_transform = new_bullet_hole.transform.looking_at(position + normal, Vector3.RIGHT.rotated(normal, random_angle))
			#new_bullet_hole.global_transform = new_bullet_hole.global_transform.scaled_local(scale)
			#
			#SpawnerManager.spawn_with_data({
				#"path": "res://scenes/entities/bullet_hole.tscn",
				#"props": {
					#"global_transform": new_bullet_hole.global_transform
				#}
			#})
			#
			#new_bullet_hole.queue_free()

func reload():
	if is_reloading:
		return
	is_gun_ready = false
	is_reloading = true
	$ReloadTimer.start(stats.reload_time * (1 - num_bullets / stats.mag_capacity))
	$ReloadSFX.play()
	animation_player.stop()
	animation_player.play("reload")

func rev():
	if is_gun_ready or is_revving:
		return
	$UnrevTimer.stop()
	$RevTimer.start()
	$RevTimer.paused = false
	is_revving = true

func unrev():
	$RevTimer.paused = true
	$UnrevTimer.start($RevTimer.wait_time - $RevTimer.time_left)

func play_shoot_effects():
	gun_effects.play_effects()
	$ShootSFX.stop()
	$ShootSFX.play()
	animation_player.stop()
	animation_player.play("shoot")

func _on_fire_timer_timeout() -> void:
	is_gun_ready = true

func _on_reload_timer_timeout() -> void:
	is_gun_ready = true
	is_reloading = false
	num_bullets = stats.mag_capacity
	ammo_changed.emit(num_bullets, stats.mag_capacity)

func _on_rev_timer_timeout() -> void:
	is_gun_ready = true
	is_revving = false

func _on_unrev_timer_timeout() -> void:
	$FireTimer.stop()
	$RevTimer.start()
	$RevTimer.stop()
	is_gun_ready = false
	is_revving = false
