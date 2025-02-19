extends Node

@onready var player: CharacterBody3D = $".."
@onready var speed_boost_timer: Timer = $SpeedBoostTimer
@onready var jump_boost_timer: Timer = $JumpBoostTimer
@onready var grappling_hook: GrapplingHook = $"../Head/Camera/GrapplingHook"

func _ready() -> void:
	grappling_hook.player = player

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
	grappling_hook.launch()
	return grappling_hook.is_launched
