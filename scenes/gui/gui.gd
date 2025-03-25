extends Control

@onready var title_screen: Control = $TitleScreen
@onready var main_menu: Control = $MainMenu
@onready var local_menu: LocalMenu = $LocalMenu
@onready var lobby_menu: LobbyMenu = $LobbyMenu
@onready var agent_map_select_menu: Control = $AgentMapSelectMenu
@onready var preliminary_screen: Control = $PreliminaryScreen
@onready var hud: HUD = $HUD
@onready var victory_screen: Control = $VictoryScreen
@onready var defeat_screen: Control = $DefeatScreen

var peer_ready_states = {}

func _on_title_screen_start_button_pressed() -> void:
	title_screen.hide()
	main_menu.show()

func _on_main_menu_local_game_button_pressed() -> void:
	main_menu.hide()
	local_menu.show()

func _on_local_menu_host_button_pressed(_room_name: String) -> void:
	lobby_menu.add_player_display(multiplayer.get_unique_id())
	lobby_menu.show()

func _on_local_menu_join_button_pressed(_ip_address: String) -> void:
	lobby_menu.show()

func _on_lobby_menu_ready_button_pressed(peer_id: int, is_ready: bool) -> void:
	update_peer_ready_states.rpc(peer_id, is_ready)

@rpc("any_peer", "call_local")
func update_peer_ready_states(peer_id, is_peer_ready):
	peer_ready_states[peer_id] = is_peer_ready
	var peer_ready_count = peer_ready_states.values().count(true)
	var are_peers_ready = peer_ready_count == multiplayer.get_peers().size()+1
	if multiplayer.get_unique_id() == 1:
		lobby_menu.set_start_button_visibility(are_peers_ready)
	else:
		lobby_menu.set_waiting_label_visibility(are_peers_ready)

func _on_lobby_menu_start_button_pressed() -> void:
	begin_agent_map_selection.rpc()

@rpc("call_local")
func begin_agent_map_selection():
	lobby_menu.hide()
	agent_map_select_menu.show()

func _on_agent_map_select_menu_finished_selection(
		_peer_id: int, _agent_name: String, _map_name: String
	) -> void:
	agent_map_select_menu.hide()
	preliminary_screen.show()

func _on_preliminary_screen_back_button_pressed() -> void:
	preliminary_screen.hide()
	agent_map_select_menu.show()

func _on_preliminary_screen_begin_button_pressed() -> void:
	prepare_for_game.rpc()

@rpc("call_local")
func prepare_for_game():
	preliminary_screen.hide()
	hud.show()

@rpc("call_local")
func prepare_for_end_game(P1_won: bool):
	hud.hide()
	if is_multiplayer_authority() == P1_won:
		victory_screen.show()
	else:
		defeat_screen.show()
