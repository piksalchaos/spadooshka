extends Control

var peer_ready_states = {}

@onready var main_menu: Control = $MainMenu
@onready var local_menu: LocalMenu = $LocalMenu
@onready var lobby_menu: LobbyMenu = $LobbyMenu

signal host_button_pressed(room_name: String)
signal join_button_pressed(ip_address: String)
signal lobby_start_button_pressed

func _on_main_menu_local_game_button_pressed() -> void:
	main_menu.hide()
	local_menu.show()

func _on_local_menu_host_button_pressed(room_name: String) -> void:
	host_button_pressed.emit(room_name)
	lobby_menu.add_player_display(multiplayer.get_unique_id())
	lobby_menu.show()

func _on_local_menu_join_button_pressed(ip_address: String) -> void:
	join_button_pressed.emit(ip_address)
	lobby_menu.show()

func _on_lobby_menu_ready_button_pressed(peer_id: int, is_ready: bool) -> void:
	update_peer_ready_states.rpc(peer_id, is_ready)

@rpc("any_peer", "call_local", "reliable")
func update_peer_ready_states(peer_id, is_peer_ready):
	peer_ready_states[peer_id] = is_peer_ready
	var peer_ready_count = peer_ready_states.values().count(true)
	var are_peers_ready = peer_ready_count == multiplayer.get_peers().size()+1
	if multiplayer.get_unique_id() == 1:
		lobby_menu.set_start_button_visibility(are_peers_ready)
	else:
		lobby_menu.set_waiting_label_visibility(are_peers_ready)

func _on_lobby_menu_start_button_pressed() -> void:
	lobby_start_button_pressed.emit()

func on_peer_connected(peer_id: int):
	lobby_menu.on_peer_connected(peer_id)

func on_peer_disconnected(peer_id: int):
	lobby_menu.on_peer_disconnected(peer_id)

func on_failed_listen_port_bind():
	local_menu.show_listener_failed_label()

func on_found_server(room_name: String, ip: String, player_count: int):
	local_menu.add_server_info_display(room_name, ip, player_count)

func on_updated_server(room_name: String, ip: String, player_count: int):
	local_menu.update_server_info_display(room_name, ip, player_count)

func on_removed_server(room_name):
	local_menu.remove_server_info_display(room_name)
