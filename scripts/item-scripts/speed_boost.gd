class_name SpeedBoost extends Item

func use() -> bool:
	return activate()

func activate():
	$ActivateSFX.play()
	$SpeedBoostTimer.start()
	player.is_speed_boosted = true
	return true

func _on_speed_boost_timer_timeout() -> void:
	$DeactivateSFX.play()
	player.is_speed_boosted = false
	self.queue_free()
