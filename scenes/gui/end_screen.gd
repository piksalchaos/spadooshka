extends Control

@onready var label: Label = $MarginContainer/Label
@onready var win_screen: TextureRect = $WinScreen
@onready var lose_screen: TextureRect = $LoseScreen

@export var text: String

signal back_button_pressed

func _ready() -> void:
	label.text = text

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func set_win_state(won_game: bool):
	if won_game:
		win_screen.show()
		lose_screen.hide()
	else:
		win_screen.hide()
		lose_screen.show()
