class_name Launchpad extends MeshInstance3D

@export var strength = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is StaticBody3D:
		return
	if body is RigidBody3D:
		body.apply_impulse(strength * basis.y.normalized())
		return
	body.velocity += strength * basis.y.normalized()
