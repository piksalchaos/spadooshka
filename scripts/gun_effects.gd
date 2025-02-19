extends Node3D

@onready var LifespanTimer = $LifespanTimer

func play_effects():
	visible = true
	$Particles.emitting = true
	LifespanTimer.start()
	

func _on_lifespan_timer_timeout() -> void:
	visible = false
	$Particles.emitting = false #shouldn't be necessary, just in case to stop consuming resources
