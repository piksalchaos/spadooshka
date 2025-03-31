class_name MinimizerItem extends EffectItem

@onready var minimizer_timer: Timer = $MinimizerTimer
@onready var activate_sfx: AudioStreamPlayer = $ActivateSFX
@onready var deactivate_sfx: AudioStreamPlayer = $DeactivateSFX

var is_active

#signal timer_began(timer: Timer)

func use() -> bool:
	activate_sfx.play()
	queue_free()
	player.apply_effect(effect_scene.instantiate())
	return true
