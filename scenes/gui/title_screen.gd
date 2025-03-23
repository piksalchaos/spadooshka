extends Control

signal start_button_pressed
signal exit_button_pressed

func _on_start_button_pressed() -> void:
	start_button_pressed.emit()

func _on_exit_button_pressed() -> void:
	exit_button_pressed.emit()
