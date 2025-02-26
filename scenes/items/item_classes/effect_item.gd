class_name EffectItem extends Item

@export var effect_scene: PackedScene

func use() -> bool:
	queue_free()
	player.apply_effect(effect_scene.instantiate())
	return true
