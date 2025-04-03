class_name LocalMenu extends Control

const SERVER_INFO_DISPLAY_SCENE = preload("res://scenes/gui/local_menu/server_info_display.tscn")

@onready var listener_failed_label: Label = $ListenerFailedLabel

@onready var server_info_container: VBoxContainer = $ServerInfoPanelContainer/ServerInfoContainer

@onready var address_entry: LineEdit = $JoinMenu/HBoxContainer/AddressEntry
@onready var join_go_button: Button = $JoinMenu/JoinGoButton

@onready var room_name_entry: LineEdit = $HostMenu/RoomNameEntry
@onready var host_button: Button = $HostMenu/HostButton

signal back_button_pressed
signal join_button_pressed(ip_address: String)
signal host_button_pressed(room_name: String)

func _on_back_button_pressed() -> void:
	back_button_pressed.emit()

func _on_room_name_entry_text_changed(new_text: String) -> void:
	var old_caret_column = room_name_entry.caret_column
	room_name_entry.text = new_text.replace(" ", "")
	room_name_entry.caret_column = old_caret_column
	host_button.disabled = room_name_entry.text.is_empty()

func _on_host_button_pressed() -> void:
	hide()
	host_button_pressed.emit(room_name_entry.text)

func _on_address_entry_text_changed(new_text: String) -> void:
	var decimal_octets = new_text.split(".")
	if decimal_octets.size() != 4:
		join_go_button.disabled = true
		return
	for octet in decimal_octets:
		if not octet.is_valid_int():
			join_go_button.disabled = true
			return
		var octet_int = int(octet)
		if octet_int < 0 or octet_int > 255:
			join_go_button.disabled = true
			return
	join_go_button.disabled = false

func _on_join_go_button_pressed() -> void:
	join_button_pressed.emit(address_entry.text)

func on_server_info_display_join_button_pressed(ip_address: String):
	join_button_pressed.emit(ip_address)

func _on_singleplayer_button_pressed() -> void:
	host_button_pressed.emit("lmao it isn't actually singleplayer")

func _on_join_localhost_button_pressed() -> void:
	join_button_pressed.emit("localhost")

func show_listener_failed_label():
	listener_failed_label.show()

func add_server_info_display(room_name: String, ip: String, player_count: int):
	var server_info_display: ServerInfoDisplay = SERVER_INFO_DISPLAY_SCENE.instantiate()
	server_info_display.name = room_name
	server_info_container.add_child(server_info_display)
	
	server_info_display.update_labels(room_name, ip, player_count)
	server_info_display.join_button_pressed.connect(on_server_info_display_join_button_pressed)

func update_server_info_display(room_name: String, ip: String, player_count: int):
	var server_info_display: ServerInfoDisplay = server_info_container.get_node(room_name)
	if server_info_display:
		server_info_display.update_labels(room_name, ip, player_count)

func remove_server_info_display(room_name: String):
	var server_info_display: ServerInfoDisplay = server_info_container.get_node(room_name)
	if server_info_display:
		server_info_display.queue_free()
