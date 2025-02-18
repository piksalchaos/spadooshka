extends Control

var map = preload("res://scenes/test_world.tscn")


func _on_button_pressed() -> void:
	get_tree().change_scene_to_packed(map)
