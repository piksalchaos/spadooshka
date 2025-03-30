class_name BilliardBall extends RigidBody3D

@export var health: int = 40

@rpc("call_local", "any_peer", "reliable")
func receive_damage(damage):
	health -= damage
	if health <= 0:
		queue_free()
