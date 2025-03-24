class_name GunStats extends Resource

# default values
enum ShootMode {AUTO, SEMI}
@export var shoot_mode: ShootMode = ShootMode.SEMI
@export var fire_time: float = 0.4
@export var reload_time: float = 1
@export var rev_time: float = 0

@export var mag_capacity: int = 5
@export var damage: int = 20
@export var shoot_range: int = 100

@export var bullet_trajectory_rot_x: float = 1
@export var bullet_trajectory_rot_z: float = 1

@export var aim_bullet_trajectory_rot_x: float = 0.2
@export var aim_bullet_trajectory_rot_z: float = 0.2
