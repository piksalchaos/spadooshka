class_name LocalMenu extends Control

const SERVER_INFO_DISPLAY_SCENE = preload("res://scenes/gui/local_menu/server_info_display.tscn")

@onready var listener_failed_label: Label = $ListenerFailedLabel
@onready var server_info_container: VBoxContainer = $ServerInfoPanelContainer/ServerInfoContainer
@onready var address_entry: LineEdit = $JoinMenu/VBoxContainer/AddressEntry

signal join_button_pressed(ip_address: String)
signal host_button_pressed
signal singleplayer_button_pressed

func _on_host_button_pressed() -> void:
	hide()
	host_button_pressed.emit()

func _on_join_go_button_pressed() -> void:
	hide()
	join_button_pressed.emit(address_entry.text)

func on_server_info_display_join_button_pressed(ip_address: String):
	hide()
	join_button_pressed.emit(ip_address)

func _on_singleplayer_button_pressed() -> void:
	hide()
	singleplayer_button_pressed.emit()

func _on_join_localhost_button_pressed() -> void:
	hide()
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
