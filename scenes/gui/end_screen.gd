extends Control

@onready var label: Label = $MarginContainer/Label

@export var text: String

func _ready() -> void:
	label.text = text
