class_name SelectableIcon extends TextureButton

signal selected(icon_name: String)

func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		selected.emit(name)
