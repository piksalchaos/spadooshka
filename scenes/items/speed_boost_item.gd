class_name SpeedBoostItem extends EffectItem

@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var activate_sfx: AudioStreamPlayer = $ActivateSFX
@onready var deactivate_sfx: AudioStreamPlayer = $DeactivateSFX

var is_active

#signal timer_began(timer: Timer)

func use() -> bool:
	activate_sfx.play()
	queue_free()
	#player.apply_effect(effect)
	return true
