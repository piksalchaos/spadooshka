class_name HealthBurger extends Item

@export var health = 50
# Called when the node enters the scene tree for the first time.
func use():
	player.receive_damage(-health)
	queue_free()
	return true
