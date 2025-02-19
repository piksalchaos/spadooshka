class_name JumpBoost extends Item
	
func use() -> bool:
	return activate()

func activate():
	$ActivateSFX.play()
	$JumpBoostTimer.start()
	player.is_jump_boosted = true
	return true

func _on_jump_boost_timer_timeout() -> void:
	$DeactivateSFX.play()
	player.is_jump_boosted = false
	self.queue_free()
