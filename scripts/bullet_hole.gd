extends MeshInstance3D

func _on_cleanup_timer_timeout() -> void:
	queue_free()
