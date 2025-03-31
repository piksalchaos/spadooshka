extends ProgressBar

@export var effect: Effect

func _process(_delta: float) -> void:
	if not effect:
		visible = false
		return
	value = effect.timer.get_effect_time_left() / effect.timer.wait_time

func start(_effect: Effect):
	visible = true
	effect = _effect
