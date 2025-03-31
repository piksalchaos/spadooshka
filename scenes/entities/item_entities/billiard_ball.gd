class_name BilliardBall extends RigidBody3D

const SPRITESHEET_COLUMNS = 4

@onready var mesh_instance_3d: MeshInstance3D = $MeshInstance3D
@onready var material: StandardMaterial3D = mesh_instance_3d.get_active_material(0)
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@export var health: int = 40
@export var texture_index: int
@export var opacity: int = 255
@export var redness: int = 0

var finished_expanding = false
var UV_offset: Vector2

func _ready():
	material.uv1_offset.x = texture_index % SPRITESHEET_COLUMNS * 0.25
	material.uv1_offset.y = floorf(float(texture_index)/SPRITESHEET_COLUMNS) * 0.25

func _process(delta: float) -> void:
	material.albedo_color.a8 = 255 - opacity
	material.albedo_color.b8 = 255 - redness
	material.albedo_color.g8 = 255 - redness

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "expand":
		finished_expanding = true
		animation_player.play("RESET")
	elif anim_name == "destroy":
		queue_free()

@rpc("call_local", "any_peer", "reliable")
func receive_damage(damage):
	if not finished_expanding: return
	animation_player.stop()
	animation_player.play("hit")
	health -= damage
	if health <= 0:
		collision_shape_3d.disabled = true
		freeze = true
		animation_player.stop()
		animation_player.play("destroy")
