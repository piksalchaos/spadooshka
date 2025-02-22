extends PanelContainer

@onready var address_entry: LineEdit = $MarginContainer/VBoxContainer/AddressEntry

signal host_button_pressed
signal join_button_pressed
signal singleplayer_button_pressed

func _on_host_button_pressed() -> void:
	hide()
	host_button_pressed.emit()

func _on_join_button_pressed() -> void:
	hide()
	join_button_pressed.emit()

func _on_singleplayer_button_pressed() -> void:
	hide()
	singleplayer_button_pressed.emit()

func get_address_entry_text():
	return address_entry.text
