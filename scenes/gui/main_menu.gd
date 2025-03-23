extends Control

signal local_game_button_pressed()

func _on_local_game_button_pressed() -> void:
	local_game_button_pressed.emit()
