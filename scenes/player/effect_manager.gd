class_name EffectManager extends Node

signal effect_applied(effect: Effect)

func apply_effect(effect: Effect):
	for i in range(get_child_count()):
		if get_child(i).effect_name == effect.effect_name:
			get_child(i).queue_free()
	add_child(effect)
	effect_applied.emit(effect)

func is_effect_applied(effect_name: String):
	for effect in get_children():
		if effect.effect_name == effect_name:
			return true
	return false

func get_effect_applied(effect_name: String):
	for effect in get_children():
		if effect.effect_name == effect_name:
			return effect
