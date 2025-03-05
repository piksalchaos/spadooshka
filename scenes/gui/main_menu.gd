class_name MainMenu extends Control

const SERVER_INFO_DISPLAY_SCENE = preload("res://scenes/gui/server_info_display.tscn")

@onready var listener_failed_label: Label = $ListenerFailedLabel
@onready var address_entry: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/AddressEntry
@onready var name_entry: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/NameEntry
@onready var server_info_container: VBoxContainer = $ServerInfoContainer

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

func get_name_entry_text():
	return name_entry.text

func show_listener_failed_label():
	listener_failed_label.show()

func add_server_info_display(room_name: String, ip: String, player_count: int):
	var server_info_display: ServerInfoDisplay = SERVER_INFO_DISPLAY_SCENE.instantiate()
	server_info_display.name = room_name
	server_info_container.add_child(server_info_display)
	server_info_display.update_labels(room_name, ip, player_count)

func update_server_info_display(room_name: String, ip: String, player_count: int):
	var server_info_display: ServerInfoDisplay = server_info_container.get_node(room_name)
	if server_info_display:
		server_info_display.update_labels(room_name, ip, player_count)

func remove_server_info_display(room_name: String):
	var server_info_display: ServerInfoDisplay = server_info_container.get_node(room_name)
	if server_info_display:
		server_info_display.queue_free()
