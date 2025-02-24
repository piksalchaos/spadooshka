class_name BulletHole extends Sprite3D

func _on_cleanup_timer_timeout() -> void:
	queue_free()
