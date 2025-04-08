extends Timer

@export var damage2time_factor: float = 0.05
var time_decrease: float = 0

func receive_damage(damage: int):
	time_decrease += damage * damage2time_factor
	if get_effect_time_left() <= 0:
		$"..".queue_free()

func get_effect_time_left():
	return time_left - time_decrease
