class_name TemporaryEffect extends Effect

@onready var timer: Timer = $Timer

func _on_timer_timeout() -> void:
	queue_free()
