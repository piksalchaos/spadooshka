extends Control

var peer_ready_states = {}

@onready var main_menu: Control = $MainMenu
@onready var local_menu: LocalMenu = $LocalMenu
@onready var lobby_menu: LobbyMenu = $LobbyMenu

signal back_button_pressed
signal local_game_button_pressed
signal local_menu_back_button_pressed
signal host_button_pressed(room_name: String)
signal join_button_pressed(ip_address: String)
signal lobby_back_button_pressed
signal lobby_start_button_pressed

func _on_main_menu_back_button_pressed() -> void:
	back_button_pressed.emit()

func _on_main_menu_local_game_button_pressed() -> void:
	local_game_button_pressed.emit()
	main_menu.hide()
	local_menu.show()

func _on_local_menu_back_button_pressed() -> void:
	local_menu_back_button_pressed.emit()
	local_menu.hide()
	main_menu.show()

func _on_local_menu_host_button_pressed(room_name: String) -> void:
	host_button_pressed.emit(room_name)
	local_menu.hide()
	lobby_menu.add_player_display(multiplayer.get_unique_id())
	lobby_menu.show()

func _on_local_menu_join_button_pressed(ip_address: String) -> void:
	join_button_pressed.emit(ip_address)

func switch_local_menu_to_lobby_menu():
	local_menu.hide()
	lobby_menu.show()

func _on_lobby_menu_back_button_pressed() -> void:
	lobby_back_button_pressed.emit()
	leave_lobby_gui()

func on_server_disconnected() -> void:
	lobby_back_button_pressed.emit()
	leave_lobby_gui()

func leave_lobby_gui():
	peer_ready_states.clear()
	lobby_menu.hide()
	lobby_menu.reset()
	local_menu.show()

func _on_lobby_menu_ready_button_pressed(peer_id: int, is_ready: bool) -> void:
	change_peer_ready_state.rpc_id(1, peer_id, is_ready)

@rpc("any_peer", "call_local", "reliable")
func remove_peer_ready_state(peer_id):
	print("WAAA")
	peer_ready_states.erase(peer_id)
	update_peer_ready_states.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func change_peer_ready_state(peer_id, is_peer_ready):
	peer_ready_states[peer_id] = is_peer_ready
	update_peer_ready_states.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func update_peer_ready_states():
	var peer_ready_count = peer_ready_states.values().count(true)
	var are_peers_ready = peer_ready_count == multiplayer.get_peers().size()+1
	update_peer_ready_state_displays.rpc(peer_ready_states, are_peers_ready)

@rpc("authority", "call_local", "reliable")
func update_peer_ready_state_displays(new_peer_ready_states, are_peers_ready):
	for peer_id in new_peer_ready_states.keys():
		lobby_menu.set_player_is_ready(peer_id, new_peer_ready_states[peer_id])
	if multiplayer.get_unique_id() == 1:
		lobby_menu.set_start_button_visibility(are_peers_ready)
	else:
		lobby_menu.set_waiting_label_visibility(are_peers_ready)
	print(peer_ready_states)

func _on_lobby_menu_start_button_pressed() -> void:
	lobby_start_button_pressed.emit()

func on_peer_connected(peer_id: int):
	lobby_menu.on_peer_connected(peer_id)
	update_peer_ready_states.rpc_id(1)

func on_peer_disconnected(peer_id: int):
	print(multiplayer.get_unique_id())
	lobby_menu.on_peer_disconnected(peer_id)
	remove_peer_ready_state.rpc_id(1, peer_id)

func on_failed_listen_port_bind():
	local_menu.show_listener_failed_label()

func on_found_server(room_name: String, ip: String, player_count: int):
	local_menu.add_server_info_display(room_name, ip, player_count)

func on_updated_server(room_name: String, ip: String, player_count: int):
	local_menu.update_server_info_display(room_name, ip, player_count)

func on_removed_server(room_name):
	local_menu.remove_server_info_display(room_name)
