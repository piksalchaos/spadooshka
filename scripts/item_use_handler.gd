extends Node

@onready var player: CharacterBody3D = $".."
@onready var camera: Camera3D = $"../Head/Camera"
@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var jump_boost_timer: Timer = $JumpBoostTimer
@onready var grapple_controller: Node = $GrappleController

func _on_inventory_use_item(item: Item) -> void:
	item.is_used = call(item.use_function)

func boost_speed() -> bool:
	speed_boost_timer.start()
	player.is_speed_boosted = true
	return true
	
func _on_speed_boost_timer_timeout() -> void:
	player.is_speed_boosted = false

func boost_jump() -> bool:
	jump_boost_timer.start()
	player.is_jump_boosted = true
	return true

func _on_jump_boost_timer_timeout() -> void:
	player.is_jump_boosted = false

func grapple() -> bool:
	grapple_controller.launch()
	return grapple_controller.is_launched
