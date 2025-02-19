extends Control

@onready var player_number_label: Label = $PlayerNumberLabel

signal ready_button_pressed()

func update_number_of_players(new_number):
	player_number_label.text = "Number of Players: " + str(new_number)

func _on_ready_button_pressed() -> void:
	hide()
	ready_button_pressed.emit()
