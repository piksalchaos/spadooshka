extends Node

@onready var player: CharacterBody3D = $".."
@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var jump_boost_timer: Timer = $JumpBoostTimer

func _on_inventory_use_item(item: Item) -> void:
	call(item.player_function_name)

func boost_speed():
	speed_boost_timer.start()
	player.is_speed_boosted = true
	
func _on_speed_boost_timer_timeout() -> void:
	player.is_speed_boosted = false

func boost_jump():
	jump_boost_timer.start()
	player.is_jump_boosted = true

func _on_jump_boost_timer_timeout() -> void:
	player.is_jump_boosted = false
