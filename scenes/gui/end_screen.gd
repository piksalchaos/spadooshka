extends Control

@onready var label: Label = $MarginContainer/Label

@export var text: String

signal back_button_pressed

func _ready() -> void:
	label.text = text

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()
