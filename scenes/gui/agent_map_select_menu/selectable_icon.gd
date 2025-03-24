class_name SelectableIcon extends TextureButton

signal selected(icon_name: String)

func _on_pressed() -> void:
	selected.emit(name)
	if button_pressed == false:
		button_pressed = true
